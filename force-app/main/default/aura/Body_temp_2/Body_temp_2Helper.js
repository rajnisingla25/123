({
	getHeadline : function(component, event, helper) {
		var copySub = component.get('v.subheadline');
        var copyHead = component.get('v.headline');
        var cityformarketinguse = component.get('v.cityformarketinguse');
        if(cityformarketinguse === undefined || cityformarketinguse === ""){
            cityformarketinguse = "your area";
        }
        
        let parserHead = new DOMParser();
        let parserSub = new DOMParser();
        
        parserHead = parserHead.parseFromString(copyHead, "text/html");
        if(parserHead.getElementById('cityformarketinguse')){
          parserHead.getElementById('cityformarketinguse').innerHTML= cityformarketinguse;
        }
        
        parserSub = parserSub.parseFromString(copySub, "text/html");
        if(parserSub.getElementById('cityformarketinguse2')){
          parserSub.getElementById('cityformarketinguse2').innerHTML= cityformarketinguse;
        }

        parserHead = parserHead.getElementsByTagName('body')[0].innerHTML;      
        parserSub = parserSub.getElementsByTagName('body')[0].innerHTML;
       
        document.getElementById('head1').innerHTML = parserHead;
        document.getElementById('subhead1').innerHTML = parserSub;
        
        document.getElementById('head2').innerHTML = parserHead;
        document.getElementById('subhead2').innerHTML = parserSub;
        
        document.getElementById('head3').innerHTML = parserHead;
        document.getElementById('subhead3').innerHTML = parserSub;
        
	}
})