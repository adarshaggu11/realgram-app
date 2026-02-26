// Firebase Cloud Functions for RealGram Push Notifications
// Deploy with: firebase deploy --only functions

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// ============================================
// 1. Send notification when a new lead is created
// ============================================
exports.sendNotificationOnNewLead = functions.firestore
  .document('leads/{leadId}')
  .onCreate(async (snap, context) => {
    const leadData = snap.data();
    const agentId = leadData.agentId;
    
    try {
      // Get agent's FCM token
      const agentDoc = await db.collection('users').doc(agentId).get();
      const agentFcmToken = agentDoc.data()?.fcmToken;
      
      if (!agentFcmToken) {
        console.log('Agent has no FCM token');
        return;
      }
      
      // Get buyer name
      const buyerDoc = await db.collection('users').doc(leadData.buyerId).get();
      const buyerName = buyerDoc.data()?.name || 'New buyer';
      
      // Send notification
      await messaging.send({
        token: agentFcmToken,
        notification: {
          title: '🔥 New Lead!',
          body: `${buyerName} is interested in your property`,
        },
        data: {
          type: 'new_lead',
          leadId: context.params.leadId,
          propertyId: leadData.propertyId,
          buyerId: leadData.buyerId,
        },
      });
      
      console.log('Lead notification sent to agent:', agentId);
    } catch (error) {
      console.error('Error sending lead notification:', error);
    }
  });

// ============================================
// 2. Send notification when a new message is sent
// ============================================
exports.sendNotificationOnNewMessage = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const chatId = context.params.chatId;
    const senderId = messageData.senderId;
    
    try {
      // Get chat participants
      const chatDoc = await db.collection('chats').doc(chatId).get();
      const chatData = chatDoc.data();
      
      // Determine recipient
      const recipientId = senderId === chatData.buyerId 
        ? chatData.agentId 
        : chatData.buyerId;
      
      // Get recipient's FCM token
      const recipientDoc = await db.collection('users').doc(recipientId).get();
      const recipientFcmToken = recipientDoc.data()?.fcmToken;
      
      if (!recipientFcmToken) {
        console.log('Recipient has no FCM token');
        return;
      }
      
      // Get sender name
      const senderDoc = await db.collection('users').doc(senderId).get();
      const senderName = senderDoc.data()?.name || 'Someone';
      
      // Send notification
      await messaging.send({
        token: recipientFcmToken,
        notification: {
          title: `💬 ${senderName}`,
          body: messageData.text || '📎 Shared an attachment',
        },
        data: {
          type: 'new_message',
          chatId: chatId,
          senderId: senderId,
          messageText: messageData.text || '',
        },
      });
      
      console.log('Message notification sent to:', recipientId);
    } catch (error) {
      console.error('Error sending message notification:', error);
    }
  });

// ============================================
// 3. Send notification when property is approved
// ============================================
exports.sendNotificationOnPropertyApproval = functions.firestore
  .document('properties/{propertyId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Check if status changed to 'approved'
    if (before.status !== 'approved' && after.status === 'approved') {
      try {
        // Get property owner's FCM token
        const ownerDoc = await db.collection('users').doc(after.ownerId).get();
        const ownerFcmToken = ownerDoc.data()?.fcmToken;
        
        if (!ownerFcmToken) {
          console.log('Owner has no FCM token');
          return;
        }
        
        // Send notification
        await messaging.send({
          token: ownerFcmToken,
          notification: {
            title: '✅ Property Approved!',
            body: `Your property "${after.title}" is now live`,
          },
          data: {
            type: 'property_approved',
            propertyId: context.params.propertyId,
          },
        });
        
        console.log('Approval notification sent to owner:', after.ownerId);
      } catch (error) {
        console.error('Error sending approval notification:', error);
      }
    }
  });

// ============================================
// 4. Send batch notifications (e.g., daily digest)
// ============================================
exports.sendDailyDigestNotification = functions.pubsub
  .schedule('every day 08:00')
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    try {
      // Get all active users
      const usersSnapshot = await db.collection('users')
        .where('verified', '==', true)
        .get();
      
      let notificationsSent = 0;
      let tokenErrors = 0;
      
      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;
        
        if (!fcmToken) {
          tokenErrors++;
          continue;
        }
        
        // Get unread count for this user (example)
        const unreadChats = await db.collection('chats')
          .where('buyerId', '==', userDoc.id)
          .where('unreadCount', '>', 0)
          .count()
          .get();
        
        if (unreadChats.data().count > 0) {
          try {
            await messaging.send({
              token: fcmToken,
              notification: {
                title: '📧 RealGram Daily Update',
                body: `You have ${unreadChats.data().count} unread messages`,
              },
              data: {
                type: 'daily_digest',
              },
            });
            notificationsSent++;
          } catch (error) {
            console.error(`Error sending to user ${userDoc.id}:`, error);
          }
        }
      }
      
      console.log(`Daily digest sent: ${notificationsSent} users, ${tokenErrors} invalid tokens`);
    } catch (error) {
      console.error('Error in daily digest:', error);
    }
  });

// ============================================
// 5. Update FCM token when it changes
// ============================================
exports.updateFcmTokenOnChange = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    if (before.fcmToken !== after.fcmToken) {
      console.log(`FCM token updated for user ${context.params.userId}`);
      // Could add logging/analytics here
    }
  });

// ============================================
// 6. Cleanup old FCM tokens
// Runs weekly to remove invalid tokens
// ============================================
exports.cleanupInvalidTokens = functions.pubsub
  .schedule('every monday 02:00')
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    try {
      const usersSnapshot = await db.collection('users').get();
      let tokensRemoved = 0;
      
      for (const userDoc of usersSnapshot.docs) {
        const fcmToken = userDoc.data().fcmToken;
        
        if (!fcmToken) continue;
        
        try {
          // Test the token by sending a dry run
          await messaging.send({
            token: fcmToken,
            dryRun: true,
          });
        } catch (error) {
          if (error.code === 'messaging/registration-token-not-registered') {
            // Token is invalid, remove it
            await db.collection('users').doc(userDoc.id).update({
              fcmToken: null,
            });
            tokensRemoved++;
          }
        }
      }
      
      console.log(`Token cleanup completed: ${tokensRemoved} tokens removed`);
    } catch (error) {
      console.error('Error in token cleanup:', error);
    }
  });

// ============================================
// 7. Send location-based notifications
// When buyer is near an agent's property
// ============================================
exports.sendLocationBasedNotification = functions.https
  .onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { userId, latitude, longitude } = data;
    const radiusKm = 1; // 1km radius
    
    try {
      // Find nearby properties
      const propertiesSnapshot = await db.collection('properties')
        .where('status', '==', 'approved')
        .get();
      
      const nearbyProperties = [];
      
      for (const propDoc of propertiesSnapshot.docs) {
        const propData = propDoc.data();
        const distance = calculateDistance(
          latitude,
          longitude,
          propData.latitude,
          propData.longitude
        );
        
        if (distance <= radiusKm) {
          nearbyProperties.push({
            ...propData,
            distance: distance,
            id: propDoc.id,
          });
        }
      }
      
      if (nearbyProperties.length > 0) {
        // Get user's FCM token
        const userDoc = await db.collection('users').doc(userId).get();
        const userFcmToken = userDoc.data()?.fcmToken;
        
        if (userFcmToken) {
          await messaging.send({
            token: userFcmToken,
            notification: {
              title: '📍 Properties Near You!',
              body: `Found ${nearbyProperties.length} properties nearby`,
            },
            data: {
              type: 'nearby_properties',
              propertyIds: nearbyProperties.map(p => p.id).join(','),
            },
          });
        }
      }
      
      return { success: true, nearbyCount: nearbyProperties.length };
    } catch (error) {
      console.error('Error in location-based notification:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

// Helper function to calculate distance between two coordinates
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// ============================================
// 8. Webhook for Razorpay payment events
// (for premium features)
// ============================================
exports.handlePaymentWebhook = functions.https
  .onRequest(async (req, res) => {
    if (req.method !== 'POST') {
      return res.status(405).send('Method Not Allowed');
    }
    
    try {
      const event = req.body;
      
      if (event.event === 'payment.authorized') {
        const { receipt } = event.payload.payment.entity;
        
        // Update user subscription in Firestore
        // ... payment handling logic
        
        console.log('Payment processed:', receipt);
      }
      
      res.status(200).json({ status: 'received' });
    } catch (error) {
      console.error('Webhook error:', error);
      res.status(500).send('Internal Server Error');
    }
  });
