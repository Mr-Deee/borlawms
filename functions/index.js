const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * Send notification to a specific device using FCM token
 * This matches your `sendNotificationToClient` method in AssistantMethod
 */
exports.sendNotificationToClient = functions.https.onCall(async (data, context) => {
    try {
        const token = data.token;
        const title = data.title;
        const body = data.body;
        const rideRequestId = data.rideRequestId;

        // Validate required fields
        if (!token) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'FCM token is required'
            );
        }

        // Build the notification message
        const message = {
            token: token,
            notification: {
                title: title || 'New Ride Request',
                body: body || 'You have a new ride request',
            },
            data: {
                type: 'immediate',
                wms_request_id: rideRequestId || '',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
                priority: 'high',
                notification: {
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    sound: 'default',
                    channelId: 'ride_requests',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                        'content-available': 1,
                    },
                },
                headers: {
                    'apns-priority': '10',
                },
            },
        };

        // Send the notification
        const response = await admin.messaging().send(message);
        console.log('✅ Notification sent successfully:', response);

        return {
            success: true,
            messageId: response,
            timestamp: new Date().toISOString(),
        };

    } catch (error) {
        console.error('❌ Error sending notification:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to send notification',
            error.message
        );
    }
});

/**
 * Send scheduled ride request notification
 */
exports.sendScheduledNotification = functions.https.onCall(async (data, context) => {
    try {
        const token = data.token;
        const title = data.title;
        const body = data.body;
        const wmsRequestId = data.wmsRequestId;
        const clientName = data.clientName;
        const clientPhone = data.clientPhone;
        const pickupLocation = data.pickupLocation;
        const scheduledTime = data.scheduledTime;

        if (!token) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'FCM token is required'
            );
        }

        const message = {
            token: token,
            notification: {
                title: title || 'Scheduled Pickup Request',
                body: body || 'You have a scheduled pickup request',
            },
            data: {
                type: 'scheduled',
                wms_request_id: wmsRequestId || '',
                client_name: clientName || '',
                client_phone: clientPhone || '',
                pickup_location: pickupLocation || '',
                scheduled_time: scheduledTime || '',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
                priority: 'high',
                notification: {
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    sound: 'default',
                    channelId: 'scheduled_rides',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                        'content-available': 1,
                    },
                },
                headers: {
                    'apns-priority': '10',
                },
            },
        };

        const response = await admin.messaging().send(message);
        console.log('✅ Scheduled notification sent:', response);

        return {
            success: true,
            messageId: response,
            timestamp: new Date().toISOString(),
        };

    } catch (error) {
        console.error('❌ Error sending scheduled notification:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to send scheduled notification',
            error.message
        );
    }
});

/**
 * Send notification to multiple devices (batch)
 */
exports.sendBatchNotifications = functions.https.onCall(async (data, context) => {
    try {
        const tokens = data.tokens;
        const title = data.title;
        const body = data.body;
        const rideRequestId = data.rideRequestId;

        if (!tokens || !Array.isArray(tokens) || tokens.length === 0) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'At least one FCM token is required'
            );
        }

        const message = {
            notification: {
                title: title || 'New Ride Request',
                body: body || 'You have a new ride request',
            },
            tokens: tokens,
            data: {
                type: 'immediate',
                wms_request_id: rideRequestId || '',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
                priority: 'high',
                notification: {
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    sound: 'default',
                    channelId: 'ride_requests',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        console.log('✅ Batch notifications sent:', response);

        return {
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount,
            results: response.responses.map(function(r, index) {
                return {
                    success: r.success,
                    messageId: r.messageId,
                    error: r.error ? r.error.message : null,
                    token: tokens[index],
                };
            }),
            timestamp: new Date().toISOString(),
        };

    } catch (error) {
        console.error('❌ Error sending batch notifications:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to send batch notifications',
            error.message
        );
    }
});

/**
 * Save FCM token for a user
 */
exports.saveFCMToken = functions.https.onCall(async (data, context) => {
    try {
        const userId = data.userId;
        const fcmToken = data.fcmToken;
        const userType = data.userType;

        if (!userId || !fcmToken) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'userId and fcmToken are required'
            );
        }

        // Determine which path to save to based on user type
        var path = '';
        if (userType === 'wms' || userType === 'artisan') {
            path = 'WMS/' + userId + '/token';
        } else if (userType === 'client') {
            path = 'Clients/' + userId + '/token';
        } else {
            // Try both paths
            await admin.database().ref('WMS/' + userId + '/token').set(fcmToken);
            await admin.database().ref('Clients/' + userId + '/token').set(fcmToken);
            return { success: true, message: 'Token saved to both WMS and Clients' };
        }

        await admin.database().ref(path).set(fcmToken);
        console.log('✅ FCM token saved for user ' + userId + ' (' + userType + ')');

        return {
            success: true,
            message: 'FCM token saved successfully',
            path: path,
        };

    } catch (error) {
        console.error('❌ Error saving FCM token:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to save FCM token',
            error.message
        );
    }
});

/**
 * Get a user's FCM token
 */
exports.getFCMToken = functions.https.onCall(async (data, context) => {
    try {
        const userId = data.userId;
        const userType = data.userType;

        if (!userId) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'userId is required'
            );
        }

        var path = '';
        if (userType === 'wms' || userType === 'artisan') {
            path = 'WMS/' + userId + '/token';
        } else if (userType === 'client') {
            path = 'Clients/' + userId + '/token';
        } else {
            // Try WMS first, then Clients
            const wmsSnapshot = await admin.database().ref('WMS/' + userId + '/token').once('value');
            if (wmsSnapshot.exists()) {
                return { success: true, token: wmsSnapshot.val(), userType: 'wms' };
            }
            const clientSnapshot = await admin.database().ref('Clients/' + userId + '/token').once('value');
            if (clientSnapshot.exists()) {
                return { success: true, token: clientSnapshot.val(), userType: 'client' };
            }
            return { success: false, token: null, message: 'Token not found' };
        }

        const snapshot = await admin.database().ref(path).once('value');
        if (!snapshot.exists()) {
            return { success: false, token: null, message: 'Token not found' };
        }

        return { success: true, token: snapshot.val(), userType: userType };

    } catch (error) {
        console.error('❌ Error getting FCM token:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to get FCM token',
            error.message
        );
    }
});


/ ==================== RECYCLING NOTIFICATION FUNCTIONS ====================

/**
 * Send recycling notification to WMS
 * This is called when a client submits a recycling request
 */
exports.sendRecyclingNotification = functions.https.onCall(async (data, context) => {
    try {
        const token = data.token;
        const recycleItemId = data.recycle_item_id || '';
        const userName = data.userName || 'A client';
        const userPhone = data.userPhone || '';
        const recycleType = data.recycleType || 'Recyclable items';
        const weight = data.weight || '';
        const location = data.location || '';
        const description = data.description || '';
        const imageUrl = data.imageUrl || '';

        if (!token) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'FCM token is required'
            );
        }

        const message = {
            token: token,
            notification: {
                title: '♻️ New Recycling Request',
                body: userName + ' wants to recycle ' + recycleType,
            },
            data: {
                type: 'recycling',
                recycle_item_id: recycleItemId,
                user_name: userName,
                user_phone: userPhone,
                recycle_type: recycleType,
                weight: weight,
                location: location,
                description: description,
                image_url: imageUrl,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
                priority: 'high',
                notification: {
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    sound: 'default',
                    channelId: 'recycling_requests',
                    priority: 'high',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                        'content-available': 1,
                    },
                },
                headers: {
                    'apns-priority': '10',
                },
            },
        };

        const response = await admin.messaging().send(message);
        console.log('✅ Recycling notification sent successfully:', response);

        return {
            success: true,
            messageId: response,
            timestamp: new Date().toISOString(),
        };

    } catch (error) {
        console.error('❌ Error sending recycling notification:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to send recycling notification',
            error.message
        );
    }
});

/**
 * Send recycling status notification to client
 * This is called when WMS accepts/declines a recycling request
 */
exports.sendRecyclingStatusNotification = functions.https.onCall(async (data, context) => {
    try {
        const token = data.token;
        const status = data.status || 'received';
        const recycleItemId = data.recycle_item_id || '';
        const messageText = data.message || 'Your recycling request has been received';
        const companyName = data.companyName || 'A recycling company';
        const userName = data.userName || '';

        if (!token) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'FCM token is required'
            );
        }

        var title = '♻️ Recycling Request Update';
        var body = messageText;

        if (status === 'accepted') {
            title = '✅ Recycling Request Accepted';
            body = companyName + ' has accepted your recycling request!';
        } else if (status === 'picked_up') {
            title = '🚛 Pickup Confirmed';
            body = companyName + ' is on the way to pick up your recyclables!';
        } else if (status === 'completed') {
            title = '🎉 Recycling Complete!';
            body = companyName + ' has successfully processed your recyclables. Thank you for recycling!';
        } else if (status === 'rejected' || status === 'declined') {
            title = '❌ Recycling Request Declined';
            body = companyName + ' cannot accept your recycling request at this time.';
        }

        const message = {
            token: token,
            notification: {
                title: title,
                body: body,
            },
            data: {
                type: 'recycling_status',
                status: status,
                recycle_item_id: recycleItemId,
                company_name: companyName,
                user_name: userName,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
                priority: 'high',
                notification: {
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    sound: 'default',
                    channelId: 'recycling_status',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                        'content-available': 1,
                    },
                },
                headers: {
                    'apns-priority': '10',
                },
            },
        };

        const response = await admin.messaging().send(message);
        console.log('✅ Recycling status notification sent:', response);

        return {
            success: true,
            messageId: response,
            timestamp: new Date().toISOString(),
        };

    } catch (error) {
        console.error('❌ Error sending recycling status notification:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to send recycling status notification',
            error.message
        );
    }
});

/**
 * Notify all recycling WMS about a new recycling request
 * This sends batch notifications to all WMS with type 'Recycle'
 */
exports.notifyAllRecyclingWMS = functions.https.onCall(async (data, context) => {
    try {
        const recycleItemId = data.recycle_item_id || '';
        const userName = data.userName || 'A client';
        const userPhone = data.userPhone || '';
        const recycleType = data.recycleType || 'Recyclable items';
        const weight = data.weight || '';
        const location = data.location || '';
        const description = data.description || '';
        const imageUrl = data.imageUrl || '';

        // Get all WMS with type 'Recycle'
        const wmsSnapshot = await admin.database().ref('WMS').once('value');
        var tokens = [];

        if (wmsSnapshot.exists()) {
            const wmsMap = wmsSnapshot.val();
            for (const key in wmsMap) {
                const wmsData = wmsMap[key];
                const wmsInfo = wmsData.wasteManagementInfo;
                if (wmsInfo && wmsInfo.WMSTYPE === 'Recycle') {
                    const token = wmsData.token;
                    if (token && token.length > 0) {
                        tokens.push(token);
                    }
                }
            }
        }

        if (tokens.length === 0) {
            return { success: false, message: 'No recycling WMS found' };
        }

        // Send batch notification
        const message = {
            notification: {
                title: '♻️ New Recycling Request',
                body: userName + ' wants to recycle ' + recycleType,
            },
            tokens: tokens,
            data: {
                type: 'recycling',
                recycle_item_id: recycleItemId,
                user_name: userName,
                user_phone: userPhone,
                recycle_type: recycleType,
                weight: weight,
                location: location,
                description: description,
                image_url: imageUrl,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
                priority: 'high',
                notification: {
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    sound: 'default',
                    channelId: 'recycling_requests',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        console.log('✅ Batch recycling notifications sent:', response);

        return {
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount,
            totalWMS: tokens.length,
            timestamp: new Date().toISOString(),
        };

    } catch (error) {
        console.error('❌ Error sending batch recycling notifications:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to send batch recycling notifications',
            error.message
        );
    }
});