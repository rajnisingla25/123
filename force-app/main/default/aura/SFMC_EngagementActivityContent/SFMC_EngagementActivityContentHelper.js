({
	addImageConnector : function(component) {
        
        var containerDiv = Document.getElementByClassName("imagedivclass");
        for(var i= 0 ; i< containerDiv.length;i++){
            console.log(containerDiv[i]);
        }
		console.log(containerDiv.length);
	}
})