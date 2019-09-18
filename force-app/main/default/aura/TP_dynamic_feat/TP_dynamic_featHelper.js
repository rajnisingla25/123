({
	getFeatHeadline : function(component, event, helper) {
		var copyFeaHead = component.get('v.headline');
        var copyHead1 = component.get('v.headline1');
        var copyHead2 = component.get('v.headline2');
        var copyHead3 = component.get('v.headline3');
        
        let parserFeaHead = new DOMParser();
        let parserHead1 = new DOMParser();
        let parserHead2 = new DOMParser();
        let parserHead3 = new DOMParser();
        parserFeaHead = parserFeaHead.parseFromString(copyFeaHead, "text/html");
        parserHead1 = parserHead1.parseFromString(copyHead1, "text/html");
        parserHead2 = parserHead2.parseFromString(copyHead2, "text/html");
        parserHead3 = parserHead3.parseFromString(copyHead3, "text/html");
        parserFeaHead = parserFeaHead.getElementsByTagName('body')[0].innerHTML;
        parserHead1 = parserHead1.getElementsByTagName('body')[0].innerHTML;
        parserHead2 = parserHead2.getElementsByTagName('body')[0].innerHTML;
        parserHead3 = parserHead3.getElementsByTagName('body')[0].innerHTML;
        
        document.getElementById('feaheadline').innerHTML = parserFeaHead;
        document.getElementById('headline1').innerHTML = parserHead1;
        document.getElementById('headline2').innerHTML = parserHead2;
        document.getElementById('headline3').innerHTML = parserHead3;
        
        
	}
})