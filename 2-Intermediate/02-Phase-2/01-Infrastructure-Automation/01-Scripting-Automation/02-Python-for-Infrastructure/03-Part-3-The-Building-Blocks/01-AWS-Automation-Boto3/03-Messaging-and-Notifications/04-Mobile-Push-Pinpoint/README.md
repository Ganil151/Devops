# 📱 Mobile Push with Amazon Pinpoint

While SNS can send push notifications, **Amazon Pinpoint** is the modern enterprise choice for cross-channel engagement (Email, SMS, Push, Voice). It's designed for scale and deep user targeting.

## 🚀 Key Concept: create_platform_endpoint
To reach a mobile device, you need to register it as an **Endpoint**. This requires a device token provided by mobile OS platforms (Firebase Cloud Messaging for Android, Apple Push Notification service for iOS).

## 🛠️ The Process
1.  **Platform Credential**: You must upload your FCM (Android) or APNs (iOS) credentials to Pinpoint.
2.  **Endpoint Registration**: Your mobile app calls `create_platform_endpoint` to register the user's specific device.
3.  **Sending**: You can send a direct message to a specific `EndpointId` or create a `Segment` of users to blast a campaign.

## 🛡️ Staff Standard Considerations
*   **Opt-out Status**: Pinpoint handles user opt-outs automatically. Before sending, always check the `OptOut` attribute of an endpoint.
*   **Demographics**: Endpoints can store user data (Device OS, Version, Attributes), allowing for highly specific targeting (e.g., "Only send to iOS 16 users").

---

## 💻 Lab: Registering a Device
See `lab.py` for a high-level implementation of endpoint registration.
