({
    doInit : function(component) {
        console.log(' entered in to do init function ');
        var vfOrigin = component.get("v.vfHost");
        window.addEventListener("message", function(event) {
            console.log(' *** event.origin *** '+event.origin);
            console.log(' *** vfOrigin **** '+vfOrigin);
            if (event.origin !== vfOrigin) {
                console.log(' event origin not equals vforigin ');
                return;
            }
            // Handle the message
            console.log(' ** event data is **** ? '+event.data);
            if(event.data === 'Payment Profile Created Successfully'){
                 location.reload();
            }
        }, false);
    }

})