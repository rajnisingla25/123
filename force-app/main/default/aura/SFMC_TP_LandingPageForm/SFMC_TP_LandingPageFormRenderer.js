({
   afterRender : function(component, helper){
      this.superAfterRender();
      document.getElementById("theButtonDemoId").addEventListener("click", $A.getCallback(function(){
            helper.handlePopUp(component, null, helper);
			
       }));
   }
})

({
	afterRender: function(component, helper) {
    this.superAfterRender();
    helper.getformHeadline(component);
  }
})