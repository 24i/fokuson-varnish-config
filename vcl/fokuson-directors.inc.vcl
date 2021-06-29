vcl 4.1;

probe clientportalProbe {
    .url = "/client-portal/ping.jsp";
}

probe epgcacheProbe {
    .url = "/epg-cache/ping.jsp";
}

# Uncomment if you are running the ads-system.
#probe adsapiProbe {
#    .url = "/ads-api/ping.jsp";
#}

# Uncomment if you run recommendation-client.war on any server
#probe recomendationclientProbe {
#    .url = "/recomendation-client/api/v1/ping.jsp";
#}

# Uncomment if you run the legacy search-client.war on any server
#probe searchclientProbe {
#    .url = "/search-client/api/v1/ping.jsp";
#}

# Uncomment this is you are running unified search anywhere
#probe unifiedsearchProbe {
#    .url = "/unified-search/actuator/health";
#}

# Uncomment if you run kids-client.war on any server
#probe kidsClientProbe {
#    .url = "/kids-client/ping.jsp";
#}

# Uncomment if you run kids-client.war on any server
#probe easserviceprobe {
#    .url = "/eas-service/actuator/health";
#}

#probe idpProbe {
#    .url = "/idp/ping";
#}

# Uncomment if you run mail-service.war
#probe mailProbe {
#    .url = "/mail-service/ping.html";
#}

probe offlineportalProbe {
    .url = "/server-status?auto";
}

# Backends
# Default connect_timeout of 3.5 seconds will allow for 2 TCP retransmissions during TCP 3-way handshake.
# We default to 1.1 second since we assume the backends are local. This should allow a single retransmission before giving up.

# The default config assumes a single application server with only client-portal and epg-cache applications deployed. Adjust and add backends to fit your deployment.

backend clientportal1 {
    .host = "localhost";
    .port = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout = 1.1s;
    .probe = clientPortalProbe;
}

/*
backend clientportal2 {
    .host = "192.0.2.2";
    .port = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout = 1.1s;
    .probe = clientPortalProbe;
}
*/

backend epgcache1 {
    .host = "localhost";
    .port = "8080";
    .first_byte_timeout = 10s;
    .connect_timeout = 1.1s;
    .probe = epgcacheProbe;
}

/*
backend epgcache2 {
    .host = "192.0.2.4";
    .port = "8080";
    .first_byte_timeout = 10s;
    .connect_timeout = 1.1s;
    .probe = epgcacheProbe;
}
*/

# Ads System. Uncomment if you have ads-system deployed.
/*
backend adsapi1 {
    .host = "192.0.2.7";
    .port = "8080";
    .first_byte_timeout = 15s;
    .connect_timeout = 1.1s;
    .probe = adsapiProbe;
}
 */

/*
backend adsapi2 {
    .host = "192.0.2.8";
    .port = "8080";
    .first_byte_timeout = 15s;
    .connect_timeout = 1.1s;
    .probe = adsapiProbe;
}
*/

# Recommendation. Uncomment you have fokusOn connected to a recommendation/prediction engine via recommendation-client.war
/*
backend recommendationclient1 {
    .host = "192.0.2.9";
    .port  = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout=1.1s; 
    .probe = recommendationProbe;
}
*/

/*
backend recommendationclient2 {
    .host = "192.0.2.10";
    .port  = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout=1.1s; 
    .probe = recommendationProbe;
}
*/

#Search-client. Uncomment if you are using search-client.war
/*
backend searchclient1 {
    .host = "192.0.2.11";
    .port = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout =  1.1s;
    .probe = searchclientProbe;
}
*/

/*
backend searchclient2 {
    .host = "192.0.2.12";
    .port = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout =  1.1s;
    .probe = searchclientProbe;
}
*/

#Unified search client. Uncomment if you are using Unified Search.
/*
backend unifiedsearch1 {
    .host = "192.0.2.13";
    .port = "8082";
    .first_byte_timeout = 30s;
    .connect_timeout =  1.1s;
    .probe = unifiedsearchProbe;
}
*/

/*
backend unifiedsearch2 {
    .host = "192.0.2.14";
    .port = "8082";
    .first_byte_timeout = 30s;
    .connect_timeout =  1.1s;
    .probe = unifiedsearchProbe;
}
*/

# Kids-client.
/*
backend kidsclient1 {
    .host = "192.0.2.15";
    .port = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout =  1.1s;
    .probe = kidsclientprobe;
}
*/

/*
backend kidsclient2 {
    .host = "192.0.2.16";
    .port = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout =  1.1s;
    .probe = kidsclientprobe;
}
*/

# EAS system
/*
backend easservice1 {
    .host = "192.0.2.17";
    .port = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout =  1.1s;
    .probe = easserviceprobe;
}
*/

/*
backend easservice2 {
    .host = "192.2.0.18";
    .port = "8080";
    .first_byte_timeout = 30s;
    .connect_timeout =  1.1s;
    .probe = easserviceprobe;
}
*/

# SSO IDP service. Uncomment if this is part of your deployment
/*
backend ssoidp1 {
    .host = "192.2.0.19";
    .port = "8320";
    .first_byte_timeout = 15s;
    .connect_timeout = 1.1s;
    .probe = idpProbe;
}
 */

/*
backend ssoidp2 {
    .host = "192.2.0.20";
    .port = "8320";
    .first_byte_timeout = 15s;
    .connect_timeout = 1.1s;
    .probe = idpProbe;
}
*/


# Mail service backend. Uncomment if mail-service.war is part of your deployment
/*
backend mailservice1 {
    .host = "192.2.0.21";
    .port = "8080";
    .first_byte_timeout = 15s;
    .connect_timeout = 1.1s;
    .probe = mailProbe;
}

backend mailservice2 {
    .host = "192.2.0.22";
    .port = "8080";
    .first_byte_timeout = 15s;
    .connect_timeout = 1.1s;
    .probe = mailProbe;
}*/

#Offline/maintenance portal
backend offlineportal1 {
    .host = "localhost";
    .port = "1080";
    .first_byte_timeout=5s;
    .connect_timeout=1.1s;
    .probe=offlineportalProbe;
}

/*
backend offlineportal2 {
    .host = "otherserver";
    .port = "1080";
    .first_byte_timeout=5s;
    .connect_timeout=1.1s;
    .probe=offlineportalProbe;
}
*/


sub vcl_init {
    # Group backends in to directors

    # Client-portal. Add any missing instances if needed
    new clientportal = directors.round_robin();
    clientportal.add_backend(clientportal1);
    #clientportal.add_backend(clientportal2);
    #...

    # Epg-cache
    new epgcache = directors.round_robin();
    epgcache.add_backend(epgcache1);
    #epgcache.add_backend(epgcache2);

    # Ads API - uncomment if needed
    #new adsapi = directors.round_robin();
    #adsapi.add_backend(adsapi1);
    #adsapi.add_backend(adsapi2);

    # Recommendation client service - uncomment if needed
    #new recommendationclient = directors.round_robin();
    #recommendationclient.add_backend(recommendationclient1);
    #recommendationclient.add_backend(recommendationclient2);

    # Unified search - uncomment if you have Unified Search
    #new unifiedsearchclient = directors.round_robin();
    #unifiedsearchclient.add_backend(unifiedsearch1);
    #unifiedsearchclient.add_backend(unifiedsearch2);

    # Search client service - uncomment if needed
    #new searchclient = directors.round_robin();
    #searchclient.add_backend(searchclient1);
    #searchclient.add_backend(searchclient2);

    # kids client service - uncomment if needed
    #new kidsclient = directors.round_robin();
    #kidsclient.add_backend(kidsclient1);
    #kidsclient.add_backend(kidsclient2);

    #EAS service
    #new easservice = directors.round_robin();
    #easservice.add_backend(easservice1);
    #easservice.add_backend(easservice2);

    #SSO IDP service
    #new ssoidp = directors.round_robin();
    #ssoidp.add_backend(ssoidp1);
    #ssoidp.add_backend(ssoidp2);

    # Mail-service
    #new mailservice = directors.fallback();
    #mailservice.add_backend(mailservice1);
    #mailservice.add_backend(mailservice2);

    # Offlineportal. Use fallback director to utilize a local Apache
    # before going over the network.
    new offlineportal = directors.fallback();
    offlineportal.add_backend(offlineportal1);
    #offlineportal.add_backend(offlineportal2);

}
