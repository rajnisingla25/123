({
	afterRender : function( component, helper ) {
        this.superAfterRender();
       
       /*//This will bring focus on div that contains body of modal and enable user to scroll by using keyboard keys.
       if(!$A.util.isEmpty(component.find('scrollableDiv')) &&
        !$A.util.isEmpty(component.find('scrollableDiv').getElement()) &&
         component.get('v.focusForKeypadScroll')){
        component.find('scrollableDiv').getElement().focus(); 
       }*/
       
       // this is done in renderer because we don't get
       // access to the window element in the helper js.
       // per John Resig, we should not take action on every scroll event
       // as that has poor performance but rather we should take action periodically.
       // http://ejohn.org/blog/learning-from-twitter/
               
       var didScroll = false;
       var modContent = component.find('modalContent').getElement();
       var mod = modContent.addEventListener('scroll', function(event) {
           didScroll = true;
       });
       // periodically attach the scroll event listener
       // so that we aren't taking action for all events
       var scrollCheckIntervalId = setInterval( $A.getCallback( function() {
           
           // since this function is called asynchronously outside the component's lifecycle
           // we need to check if the component still exists before trying to do anything else
           
           if ( didScroll && component.isValid() ) {
               //helper.fireCompEvent(component, helper, component.get( 'v.onScrollAction' ));
               didScroll = false;
               // adapted from stackoverflow to detect when user has scrolled sufficiently to end of document
               // http://stackoverflow.com/questions/4841585/alternatives-to-jquery-endless-scrolling
               //if ( window['scrollY'] >= document.body['scrollHeight'] - window['outerHeight'] - 100 ) {
               
               if((modContent.scrollTop !== 0 && modContent.scrollTop + modContent.offsetHeight) >= modContent.scrollHeight - 1 ){
                   
                   var lastPageNumber = component.get('v.lastPageNumber');
                   var pageSize = component.get('v.pageSize');
                   var totalSize = component.get('v.totalSize');
                   
                   var totalPage = Math.ceil(totalSize / pageSize);
           		   var newOffset = 0;	                  
                   if(totalPage > lastPageNumber){                      
                       component.set('v.Spinner',true);
                       newOffset = lastPageNumber * pageSize;                       
                       helper.getActivityList(component,helper,newOffset,true,lastPageNumber+1);                                              
                   }
               }
           }
       }), 1000 );
       
       component.set( 'v.setIntervalId', scrollCheckIntervalId );
    },

    unrender: function( component, helper ) {

        this.superUnrender();

        // Since setInterval() will be called even after component is destroyed
        // we need to remove it in the unrender
        window.clearInterval( component.get( "v.setIntervalId" ) );
    }
})