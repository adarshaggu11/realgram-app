const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// ===================== FUNCTION 1: Send FCM on New Lead =====================
exports.sendLeadNotificationToAgent = functions.firestore
  .document('leads/{leadId}')
  .onCreate(async (snap, context) => {
    const lead = snap.data();
    const leadId = context.params.leadId;

    try {
      // Get agent details
      const agentDoc = await db.collection('users').doc(lead.agentId).get();
      const buyer = await db.collection('users').doc(lead.buyerId).get();
      const property = await db.collection('properties').doc(lead.propertyId).get();

      if (!agentDoc.exists) return;

      const agent = agentDoc.data();
      const buyerData = buyer.data();
      const propertyData = property.data();

      // Get agent's FCM token (store in users collection)
      const fcmToken = agent.fcmToken;
      if (!fcmToken) {
        console.log('No FCM token for agent');
        return;
      }

      // Send notification
      const payload = {
        notification: {
          title: 'New Lead! 🎯',
          body: `${buyerData.name} is interested in "${propertyData.title}"`,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        data: {
          leadId: leadId,
          propertyId: lead.propertyId,
          screen: 'lead_detail',
        },
      };

      await messaging.sendToDevice(fcmToken, payload);
      console.log('Notification sent to agent:', lead.agentId);

    } catch (error) {
      console.error('Error sending lead notification:', error);
    }
  });

// ===================== FUNCTION 2: Send FCM on New Message =====================
exports.sendMessageNotification = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const { chatId } = context.params;

    try {
      // Get chat details
      const chatDoc = await db.collection('chats').doc(chatId).get();
      const chat = chatDoc.data();

      // Determine recipient and sender
      const recipientId =
        message.senderId === chat.buyerId ? chat.agentId : chat.buyerId;
      const senderDoc = await db.collection('users').doc(message.senderId).get();

      // Get recipient's FCM token
      const recipientDoc = await db.collection('users').doc(recipientId).get();
      const fcmToken = recipientDoc.data()?.fcmToken;

      if (!fcmToken) return;

      const payload = {
        notification: {
          title: senderDoc.data().name,
          body: message.text.substring(0, 100),
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        data: {
          chatId: chatId,
          screen: 'chat_detail',
        },
      };

      await messaging.sendToDevice(fcmToken, payload);
      console.log('Message notification sent');

    } catch (error) {
      console.error('Error sending message notification:', error);
    }
  });

// ===================== FUNCTION 3: Sync Lead Status Count =====================
exports.updateAgentLeadStats = functions.firestore
  .document('leads/{leadId}')
  .onWrite(async (change, context) => {
    const lead = change.after.data();

    try {
      // Update agent's totalLeads count
      const agentDoc = await db.collection('users').doc(lead.agentId).get();
      const agent = agentDoc.data();

      // Count leads for this agent
      const leadsSnapshot = await db
        .collection('leads')
        .where('agentId', '==', lead.agentId)
        .get();

      const totalLeads = leadsSnapshot.size;

      // Update user
      await db.collection('users').doc(lead.agentId).update({
        totalLeads: totalLeads,
      });

      console.log(`Updated agent ${lead.agentId} totalLeads to ${totalLeads}`);

    } catch (error) {
      console.error('Error updating agent stats:', error);
    }
  });

// ===================== FUNCTION 4: Handle Property View Count =====================
exports.incrementPropertyViews = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User not authenticated');
  }

  const { propertyId } = data;

  try {
    const propertyRef = db.collection('properties').doc(propertyId);

    // Increment views
    await propertyRef.update({
      views: admin.firestore.FieldValue.increment(1),
    });

    console.log('Property views incremented:', propertyId);

    return { success: true };

  } catch (error) {
    console.error('Error incrementing views:', error);
    throw new functions.https.HttpsError('internal', 'Internal server error');
  }
});

// ===================== FUNCTION 5: Boost Expiry Scheduler =====================
exports.expireBoosts = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    try {
      const now = admin.firestore.Timestamp.now();

      // Get properties with expired boosts
      const expiredBoosts = await db
        .collection('properties')
        .where('boostExpiry', '<', now)
        .where('boostLevel', '>', 0)
        .get();

      console.log(`Found ${expiredBoosts.size} properties with expired boosts`);

      // Reset boost level
      const batch = db.batch();
      expiredBoosts.forEach((doc) => {
        batch.update(doc.ref, {
          boostLevel: 0,
          boostExpiry: null,
        });
      });

      await batch.commit();
      console.log('Boost expiry completed');

    } catch (error) {
      console.error('Error in boost expiry:', error);
    }
  });

// ===================== FUNCTION 6: Cleanup Old Chats =====================
exports.cleanupOldChats = functions.pubsub
  .schedule('every 1 days')
  .onRun(async (context) => {
    try {
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

      // Mark chats as archived if last message was 30+ days ago
      const oldChats = await db
        .collection('chats')
        .where('lastMessageTime', '<', thirtyDaysAgo)
        .where('isArchived', '==', false)
        .get();

      const batch = db.batch();
      oldChats.forEach((doc) => {
        batch.update(doc.ref, { isArchived: true });
      });

      await batch.commit();
      console.log(`Archived ${oldChats.size} old chats`);

    } catch (error) {
      console.error('Error in cleanup:', error);
    }
  });

// ===================== FUNCTION 7: Razorpay Webhook Handler =====================
exports.handlePaymentWebhook = functions.https.onRequest(async (req, res) => {
  const crypto = require('crypto');

  try {
    const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
    const body = req.rawBody;
    const signature = req.headers['x-razorpay-signature'];

    // Verify webhook signature
    const hashedBody = crypto
      .createHmac('sha256', secret)
      .update(body)
      .digest('hex');

    if (hashedBody !== signature) {
      return res.status(400).json({ error: 'Invalid signature' });
    }

    const event = req.body;

    if (event.event === 'payment.authorized' || event.event === 'payment.captured') {
      const payment = event.payload.payment.entity;
      const notes = payment.notes;

      // Update subscription or boost in Firestore
      if (notes.type === 'subscription') {
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + 30); // 30 days premium

        await db.collection('users').doc(notes.userId).update({
          subscriptionType: 'agent_pro',
          subscriptionExpiry: expiryDate,
        });

        console.log(`Subscription activated for user ${notes.userId}`);
      }

      if (notes.type === 'boost') {
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + 7); // 7 days boost

        await db.collection('properties').doc(notes.propertyId).update({
          boostLevel: notes.boostLevel || 1,
          boostExpiry: expiryDate,
        });

        console.log(`Boost activated for property ${notes.propertyId}`);
      }
    }

    return res.status(200).json({ status: 'ok' });

  } catch (error) {
    console.error('Webhook error:', error);
    return res.status(500).json({ error: error.message });
  }
});

// ===================== FUNCTION 8: Auto-Approve for Trusted Agents =====================
exports.autoApproveProperty = functions.firestore
  .document('properties/{propertyId}')
  .onCreate(async (snap, context) => {
    const property = snap.data();

    try {
      const ownerDoc = await db.collection('users').doc(property.ownerId).get();
      const owner = ownerDoc.data();

      // Auto-approve if agent is verified and has good track record
      if (owner.verified && (owner.approvedListings || 0) > 5) {
        await snap.ref.update({
          status: 'approved',
          approvedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Auto-approved property ${context.params.propertyId}`);

        // Send notification to agent
        const fcmToken = owner.fcmToken;
        if (fcmToken) {
          await messaging.sendToDevice(fcmToken, {
            notification: {
              title: 'Property Approved! ✅',
              body: `Your listing "${property.title}" is now live.`,
            },
            data: {
              propertyId: context.params.propertyId,
              screen: 'property_detail',
            },
          });
        }
      } else {
        // Notify admin to review
        console.log(`Property ${context.params.propertyId} pending admin review`);
      }

    } catch (error) {
      console.error('Error in auto-approve:', error);
    }
  });

console.log('All Cloud Functions deployed successfully');
