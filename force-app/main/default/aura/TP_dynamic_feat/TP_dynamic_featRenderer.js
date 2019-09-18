({
	afterRender: function(component, helper) {
    this.superAfterRender();
    helper.getFeatHeadline(component);
  }
})