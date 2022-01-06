# Managing maintenance portal and offline-portal with Varnish 6 #

This document describes how to set up and operate both the legacy offline-portal and the online mainteance portal with Varnish 6.

Both the legacy offline-portal and the online-maintenance portal is a set of static files that must reside on a webserver that can be reached from Varnish. It is usually deployed on a webserver on the Varnish servers themselves, since the amount of traffic that they need to serve is minimal. This avoids the need for an extra set of servers in your fokusOn environment. 

## Types of maintenance portals ##

With the introduction of Varnish 6, fokusOn now supports multiple maintenance portals. 

Offline-portal. This provides a static channel list for multicast channels to allow basic zapping. The offline-portal is supported only on already integrated devices. No new device implementations will be made for the offline-portal. The offline-portal will be removed when support for all the currently supported devices has ended.

Along with Varnish 6, a new maintenance portal has been introduce, which is called the Online fallback portal. This serves the same purpose for multiscreen devices as the offline-portal has been serving for STB devices. It will provide a message on the screen of multiscreen devices, explaining to the user that that the backend system is under maintenance or similar. No channel zapping is available for the online fallback portal, since no CA tokens or playbak session URLS can be served when the backend is unavailable.

As a replacement for the offline portall newly integrated devices should use the "embedded fallback portal". This is a scraped version of the online portal (the normal fokusOn portal), that is embedded in to the bootimage or firmware of the STB. This allows the user to navigate the menus of the STB even while the system is offline, and will show explanative error messages when the user tries to activate something that is not available in offline-mode. 

In varnish context and the rest of the document, offline-portal will refer to all of the above maintenance portals unless specifically stated otherwise. 

## Configuring the offline-portal with Varnish 6 ###

To make the offline-portal work at the same time as the online fallback portal, you need to match you devices in Varnish based on the incoming heartbeat or healthcheck request from the client. This match can be done on the User-Agent header or in some cases the Host-header if multiscreen devices are served from different domains than the STB's. The Varnish 6 template provided by 24i includes an example on how to match on User-Agent headers.
Please note that the example assumes that the offline-portal is served from the directory /offline-portal/ on the webserver. You must adjust all absolute links in the offline-portal files to point to that path to avoid problems. 
The varnish 6 config for the Oflline-portal includes all necessary URL rewrites, so mod_rewrite is no longer needed on the Apache webserver serving the offline-portal.

The online maintenance portal must reside in the webserver root of your webserver. It's recommended to set up health-check probes on the webserver to enable Varnish to only send requests to healthy servers. The default 24i Varnish 6 config includes probes for checking an Apache server using mod_status configured on `/server_status`. If you are using a different webserver


## Activating maintenance portal on a running Varnish instance. 
To activate offline-portal on a running Varnish 6 instance, you just need to ensure that the file `/etc/varnish/offline-portal.enabled` exists. To switch it off again, just move the file out of the way -as per the following example:

**Activate offline-portal**
`touch /etc/varnish/offline-portal.enabled`

**Deactivate offline-portal**
`rm -f /etc/varnish/offline-portal.enabled`

This should be done on all Varnish 6 instances at the same time to ensure that devices are receiving the same response no matter what Varnish 6 instance they are connecting to.

The embedded fallback portal is not served from Varnish but uses the same endpoint to check activation-status as the online fallback portal, which is why it is relevant in Varnish 6 content. Since the embedded fallback portal is part of the firmware/bootimage of the STB, it is not covered in details here. This document only describes to centrally make the STB switch to the embedded fallback portal and back.
Please also note that if the STB is unable to reach the Varnish server(s), it will also switch to embedded fallback portal independent of the activation state on Varnsh 6. 

## Controlling the rate at which users return to the normal portal. ##
### Oflline-portal ###
The index.html of the offline-portal includes the following section where you can control how often the offline-portal checks if the normal portal is back:

`    function startChecking() {
        checkIfPortalIsReady.periodical(1000 * 60 * 5); // Check every 5 minutes if main portal is ready
    }

    startChecking.delay(Math.round(Math.random()*(1000*60*5)));`
    
To check every 20 minutes, change 5 to 20 in both lines. We recommend that you use an interval of at least 20 minutes for production setups with more than 20.000 active users.

### Online fallback portal ###
The online fallback portal will check in every 5 minutes with the backend to know if the normal portal should be loaded. It will then wait a random period of time before loading the offline-portal. The upper bound for this waiting time is governed by the header "Random-Max-Delay" sent from Varnish. This header is defined in vcl_synth. To edit it, you just edit the folowing line in fokuson.vcl and reload your varnish config:

`        set resp.http.Random-Max-Delay = "300s";`

For production setups with more than 20.000 active users, we recommend that you set it to at least 1200s. The only recognised unit for this header is seconds.


