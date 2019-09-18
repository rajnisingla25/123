({
	afterRender: function(component, helper) {
    this.superAfterRender();
    helper.getHeadline(component);
  }
})