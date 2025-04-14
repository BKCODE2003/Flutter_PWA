const CACHE_NAME = 'taskverse-cache-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/flutter_bootstrap.js',
  '/splash/img/light-1x.png',
  '/splash/img/light-2x.png',
  '/splash/img/dark-1x.png',
  '/splash/img/dark-2x.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  // Add other resources that are critical to load when offline
];

// Install event: Cache important assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Service Worker: Caching assets');
        return cache.addAll(urlsToCache);
      })
      .catch((error) => {
        console.error('Service Worker: Failed to cache', error);
      })
  );
  self.skipWaiting(); // Activate new SW immediately
});

// Activate event: Clean up old caches
self.addEventListener('activate', (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (!cacheWhitelist.includes(cacheName)) {
            console.log(`Service Worker: Deleting old cache ${cacheName}`);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim(); // Take control immediately
});


self.addEventListener('fetch', (event) => {
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        if (cachedResponse) {
          console.log(`Service Worker: Serving from cache - ${event.request.url}`);
          return cachedResponse;
        }
  
        return fetch(event.request)
          .then((networkResponse) => {
            // Only cache valid GET responses
            if (
              networkResponse &&
              networkResponse.status === 200 &&
              event.request.method === 'GET'
            ) {
              const responseClone = networkResponse.clone(); // 👈 Clone before reading
              caches.open(CACHE_NAME).then((cache) => {
                cache.put(event.request, responseClone);
              });
            }
  
            return networkResponse;
          })
          .catch((error) => {
            console.error(`Service Worker: Fetch failed - ${event.request.url}`, error);
            return caches.match('/offline.html');
          });
      })
    );
});
  

// Background Sync event
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-taskverse-data') {
    event.waitUntil(
      // Simulated sync task
      (async () => {
        console.log('Service Worker: Background sync triggered!');
        // Here you could sync offline-stored tasks to Firebase/Firestore
      })()
    );
  }
});

// Push Notification event
self.addEventListener('push', (event) => {
  console.log('Service Worker: Push Received.');
  let data = {};
  if (event.data) {
    data = event.data.json();
  }

  const title = data.title || 'Taskverse Notification';
  const options = {
    body: data.body || 'You have a new task update.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
  };

  event.waitUntil(self.registration.showNotification(title, options));
});
