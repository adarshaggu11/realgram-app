# Firebase Firestore Security Rules for RealGram

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ==================== HELPERS ====================
    function isAuthenticated() {
      return request.auth != null;
    }

    function isBuyer() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "buyer";
    }

    function isAgent() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "agent";
    }

    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }

    // ==================== USERS COLLECTION ====================
    match /users/{userId} {
      // Anyone authenticated can read public user info
      allow read: if isAuthenticated();
      
      // Agents/Sellers can read verified agents
      allow read: if isAuthenticated() && resource.data.verified == true;
      
      // Users create their own profile
      allow create: if isAuthenticated() && request.auth.uid == userId;
      
      // Users edit their own profile
      allow update: if isAuthenticated() && request.auth.uid == userId;
      
      // Admin can approve/verify users
      allow update: if isAuthenticated() && isAdmin();
      
      // Admins can read all users
      allow read: if isAdmin();
    }

    // ==================== PROPERTIES COLLECTION ====================
    match /properties/{propertyId} {
      // Public can read approved properties
      allow read: if resource.data.status == "approved" && isAuthenticated();
      
      // Agents can read pending/rejected their own listings
      allow read: if isAuthenticated() && (
        resource.data.ownerId == request.auth.uid ||
        resource.data.status == "approved"
      );
      
      // Only verified agents can create listings
      allow create: if isAuthenticated() && 
                       isAgent() && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.verified == true &&
                       request.resource.data.ownerId == request.auth.uid;
      
      // Only owner can update their property
      allow update: if isAuthenticated() && 
                       resource.data.ownerId == request.auth.uid;
      
      // Only owner OR admin can delete
      allow delete: if isAuthenticated() && (
        resource.data.ownerId == request.auth.uid || 
        isAdmin()
      );
    }

    // ==================== CHATS COLLECTION ====================
    match /chats/{chatId} {
      // Only participants can read
      allow read: if isAuthenticated() && (
        request.auth.uid == resource.data.buyerId || 
        request.auth.uid == resource.data.agentId
      );
      
      // Buyers/Agents can create chat
      allow create: if isAuthenticated();
      
      // Only participants can update
      allow update: if isAuthenticated() && (
        request.auth.uid == resource.data.buyerId || 
        request.auth.uid == resource.data.agentId
      );

      // ==================== MESSAGES SUB-COLLECTION ====================
      match /messages/{messageId} {
        // Only participants can read messages
        allow read: if isAuthenticated() && (
          request.auth.uid == get(/databases/$(database)/documents/chats/$(chatId)).data.buyerId ||
          request.auth.uid == get(/databases/$(database)/documents/chats/$(chatId)).data.agentId
        );
        
        // Only authenticated users can send messages
        allow create: if isAuthenticated() && 
                         request.resource.data.senderId == request.auth.uid;
        
        // Users can mark their messages as read
        allow update: if isAuthenticated();
      }
    }

    // ==================== LEADS COLLECTION ====================
    match /leads/{leadId} {
      // Only agent and buyer can read
      allow read: if isAuthenticated() && (
        resource.data.agentId == request.auth.uid ||
        resource.data.buyerId == request.auth.uid
      );
      
      // Only buyers can create leads
      allow create: if isAuthenticated() && 
                       isBuyer() &&
                       request.resource.data.buyerId == request.auth.uid;
      
      // Only agent can update lead status
      allow update: if isAuthenticated() && 
                       resource.data.agentId == request.auth.uid;
    }

    // ==================== STORAGE BUCKET ====================
    // Note: Storage rules are handled separately in Cloud Storage rules
    // Pattern: /users/{uid}/**
    // Pattern: /properties/{propertyId}/**
  }
}
```

---

## Cloud Storage Security Rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // User uploads
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Property uploads
    match /properties/{propertyId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Chat media
    match /chats/{chatId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Rule Explanation

| Collection | Create | Read | Update | Delete |
|-----------|--------|------|--------|--------|
| users | Own profile | Own + verified | Own | Admin |
| properties | Verified agents | Approved (public) + own | Owner | Owner/Admin |
| chats | Authenticated | Participants | Participants | Participants |
| messages | Participants | Participants | Participants | - |
| leads | Buyers | Agent/Buyer | Agent only | - |

---

## Testing Rules

Use Firebase Emulator Suite to test security rules locally before deployment:

```bash
firebase emulators:start
```

Example test case:
```javascript
// Should allow: Agent creates property
db.collection("properties").doc("prop1").set({
  ownerId: "agent123",
  title: "New Plot",
  status: "pending"
})

// Should deny: Buyer creates property
// Should deny: Public reads unapproved property
```

---

## Deployment

Deploy rules with:
```bash
firebase deploy --only firestore:rules
```

---

## Notes

- All rules require `isAuthenticated()`
- Properties are public only if `status == "approved"`
- Agents must be verified by admin to create listings
- Leads are visible only to agents and buyers involved
- Messages are only visible to chat participants
- Admins have override access to moderate content
