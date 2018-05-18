importScripts('https://storage.googleapis.com/workbox-cdn/releases/3.2.0/workbox-sw.js');

workbox.core.setCacheNameDetails({
  prefix: 'upm',
  suffix: 'v1',
});

// replaced by workbox during build:
workbox.precaching.precacheAndRoute([]);


workbox.routing.registerRoute(
  new RegExp('^https://fonts.(?:googleapis|gstatic).com/(.*)'),
  workbox.strategies.cacheFirst(),
);


workbox.routing.registerRoute(
  '/',
  workbox.strategies.networkFirst()
);

workbox.skipWaiting();
workbox.clientsClaim();
