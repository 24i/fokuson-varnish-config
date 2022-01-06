vcl 4.1;

import std;
import directors;

# Define probes, backends and directors etc in a separate file to keep this file as generic as possible.
include "/etc/varnish/fokuson-directors.inc.vcl";


sub offline_portal {
    if (req.url ~ "^/healthcheck/portal-status"){
        return (synth(11200,"OK"));
    }

    /* If request was a heartbeat, return 410 gone, which forces  stb's to reload the portal */
    if (req.url ~ "^/client-portal(/restricted)?/dwr/call/plaincall/DeviceFacade.getHeartbeatEvents.dwr$"){
        return(synth(410,"Gone"));
    }
    if (req.url ~ "^/client-portal/auth/rs/device/heartbeat$"){
        return(synth(410,"Gone"));
    }

    /* test-URL's in offline-portal */
    if (req.url == "/nonexistent"){
        return(synth(410,"Gone"));
    }
    if (req.url == "/dwr/index.html"){
        return(synth(410,"Gone"));
    }
    //Rewrite start URL's to hit the online-maintenance portal
    if (req.url ~ "^/client-portal/(custom|device)/"){
        // Use the following if statement to identify devices that needs to run the legacy offline-portal E.g.
        // "<user-agent1>" and "<user-agent2>". Adapt to match your detployment. 
        if (req.http.User-Agent ~ "(<user-agent1>|<user-agent2>)"){
            set req.url = "/offline-portal/index.html";
        } else {
            if (req.http.Accept ~ "text/html"){
                set req.url = "/";
            } else {
                set req.url = regsub(req.url, ".*(/\w+(\.\w+(\?\w*)?)?$)","\1");
            }
        }       
    }

    set req.backend_hint = offlineportal.backend();
    set req.http.Avoid-Caching = "true";

    // bypass all other logic
    return (pass);
}

sub vcl_recv {
    if (std.file_exists("/etc/varnish/offline-portal.enabled")){
        call offline_portal;
    }
    if (req.url ~ "^/healthcheck/portal-status"){
        return (synth(10200,"OK"));
    }
    # Set a common hostname to ensure any redirects has the correct hostname
    set req.http.Host = "fokuson.example.org";

    /* Log X-Forwarded-For column in Varnishncsa without the LB. Use this if your LB ends up in the XFF header */
    if (req.http.X-Forwarded-For ~ ","){
        std.log("XFF:" + regsub(req.http.X-Forwarded-For, "(.*), [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$", "\1"));
    }

    #Rewrite "/" to hit the multiscreen app startpage  
    set req.url = regsub(req.url, "^/(\?.*)?$", "/client-portal/custom/multiscreen/\1");
    # If you need to run on anything else than / set FO-Context-Path to that path to make relative links correct on the backend.
    #set req.http.FO-Context-Path = "/";

    #Remove anything you don't need here.
    if (req.url !~ "^/(client-portal|epg-cache|token-service|ads-api|unified-search|search-client|idp|mail-service)/"){
         set req.url = regsub(req.url ,"^/", "/client-portal/");
    }

    # Make sure we are defaulting to a director and not the first backend
    set req.backend_hint = clientportal.backend();

    # Move the original cookie header to a different header and explicitly extract the ones we need
    if (req.http.Cookie) {
        std.collect(req.http.Cookie, "; ");
        set req.http.OrigCookie = req.http.Cookie;
        unset req.http.Cookie;
        #Put ACCESS-KEY as a separate X-Access-Key header if needed.
        if (!req.http.X-Access-Key && req.http.OrigCookie ~ "(^|;)\s*ACCESS_KEY=[^;]+" ){
	    set req.http.Access-Key = regsub(req.http.OrigCookie, "(^|.*;)\s*ACCESS_KEY=([^;]+)($|.*)","\2");
        }

	# Copy any preview cookies back to the Cookie string
	if (req.http.OrigCookie ~ "(^|;\s*)preview(_[0-9a-fA-F]{2}){6}=true"){
	   if (req.http.Cookie) {
	       std.log("Cookie header already present: " + req.http.Cookie);
	       set req.http.Cookie = req.http.Cookie +  "; " + regsub(req.http.OrigCookie, "(^|.*\s+)(preview(_[0-9a-fA-F]{2}){6}=true).*","\2");
	   } else {
	       std.log("No Cookie header present");
	       set req.http.Cookie = regsub(req.http.OrigCookie, "(^|.*\s+)(preview(_[0-9a-fA-F]{2}){6}=true).*","\2");
	   }	   
        }
    }

    # Routing to client-portal
    if (req.url ~ "^/client-portal(/)?"){
        set req.backend_hint = clientportal.backend();
    }

    # EPG-cache
    if (req.url ~ "^/epg-cache(/)?"){
        //Don't allow clients to refresh the EPG-cache.
        if (req.url ~ "^/epg-cache/refresh"){
            return (synth(403, "Access denied"));
        }
        set req.backend_hint = epgcache.backend();
 
    }

    # Ads-system
    /*
    if (req.url ~ "^/ads-api($|/)"){
        set req.backend_hint = adsapi.backend();
    }
    */
    
    # Recommendation client service
    /*
    if (req.url ~ "^/recommendation-client($|/)"){
        set req.backend_hint = recommendationclient.backend();
    }
    */

    # Unified search 
    /*
    if (req.url ~ "^/unified-search($|/)"){
        set req.backend_hint = unifiedsearchclient.backend();
    }
    */

    # Search client service
    /*
    if (req.url ~ "^/search-client($|/)"){
        set req.backend_hint = searchclient.backend();
    }
    */


    # Kids-client
    /*
    if (req.url ~ "^/kids-client($|/)"){
        set req.backend_hint = kidsclient.backend();
    }
    */    

    # EAS-service
    /*
    if (req.url ~ "^/eas-service($|/)"){
        set req.backend_hint = easservice.backend();
    }
    */

    # SSO IDP service
    /*
    if (req.url ~ "^/idp/"){
        set req.backend_hint = ssoidp.backend();
    }
    */

    # Mail service
    /*
    if (req.url ~ "^/mail-service/"){
        set req.backend_hint = mailservice.backend();
    } */

    set req.http.X-Use-ESI = "true";
}

# HTTP keepalive for pipe is unsafe if we have a multiplexing LB in
# front of Varnish - especially with URL rewrites in place.
sub vcl_pipe {
  set bereq.http.connection = "close";
}

sub vcl_backend_response {

    set beresp.http.Backend-Name = beresp.backend.name;

    unset beresp.http.X-Powered-By;
    set beresp.http.Server = "fokusOn Appserver";

    //gzip everything that is worth gzip'ing - except for very small responses
    if (beresp.http.Content-Type ~ "^(text/(javascript|plain|html|css)|application/(json|(x-)?javascript|xml))"){
        if (!(beresp.http.Content-Length && std.integer(beresp.http.Content-Length, 151) < 150)){
            set beresp.do_gzip = true;
        }
    } 
    if (beresp.http.X-Use-ESI) {
        set beresp.do_esi=true;
    }

    if (beresp.http.FO-Keep){
        set beresp.keep = std.duration(beresp.http.FO-Keep,0s);
        if (!beresp.was_304){
            //Initial backend request. Store the TTL on the object.
            set beresp.http.TTL = beresp.ttl;
        } else {
            # Revalidated from backend. Set the TTL based on previously stored value.
            set beresp.ttl = std.duration(beresp.http.TTL+"s", 120s);
        }
    }

    // Avoid caching the offline-portal on clients and in Varnish.
    if (bereq.http.Avoid-Caching == "true"){
        unset beresp.http.Expires;
        unset beresp.http.ETag;
        unset beresp.http.Last-Modified;
     
        set beresp.http.Cache-Control = "max-age=0, no-cache, no-store";
        set beresp.ttl = 0s;
        set beresp.keep = 0s;
        set beresp.grace = 0s;
    }
}

sub vcl_deliver {
    # FO-keep and TTL is only intended for Varnish
    unset resp.http.FO-Keep;
    unset resp.http.TTL;

    # Log the backend name - but not for cache hits.
    if (obj.hits == 0){
        std.log("backend:" + resp.http.Backend-Name);
    }
    # Don't give away backend names to clients. Primarily for security reasons.
    unset resp.http.Backend-Name;
}

sub vcl_backend_error {
    if (bereq.url ~ "^/token-service/" ){
        # Something went wrong when fetching ESI body. Generate a json error message
        set beresp.status = 200;
        set beresp.http.Cache-Control = "private, no-cache, no-store, max-age=0";
        set beresp.http.Content-Type = "application/json";
        synthetic({" { "error": "Error fetching token via ESI request. XID: "} + bereq.xid + {", Server ID: "} + server.identity + {" " }"});
        return (deliver);
    }
}

sub vcl_synth {
    # Normal portal should be used.
    if (resp.status == 10200){
        set resp.http.Online-Status = "Online";
        set resp.http.Random-Max-Delay = "300s";
        set resp.http.Cache-Control = "private, no-cache, no-store, max-age=0";
        set resp.http.Content-Type = "application/json";
        synthetic("{}");
        return (deliver);
    }
    #Offline-portal health-check
    if (resp.status == 11200){
        #Offline portal is activated. Tell the client why.
        set resp.http.Online-Status = "Offline";
        set resp.http.Reason = "Upgrade";
        set resp.http.Description = "System upgrade in progress";
        set resp.http.Cache-Control = "private, no-cache, no-store, max-age=0";
        set resp.http.Content-Type = "application/json";
        synthetic(std.fileread("/etc/varnish/offline-portal.json"));
        return (deliver);
    }
}

/*
Custom status code list:

1xyyy Offline-portal related.
10200: Normal portal is running. Devices must load it if they are running in offline-mode.
11200: Offline-portal is activated. Devices must load the offline-portal if they are not already in offline-mode.
*/
