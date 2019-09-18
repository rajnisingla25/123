({
    fetchListings : function(component,recordId) {
        console.log('recordId-->' + recordId);
        var action = component.get('c.fetchListings');
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state-->' + state+response);
            if (state === "SUCCESS") {
                var today = new Date();
                console.log(response.getReturnValue());
                try{
                     var obj = JSON.parse(response.getReturnValue())["properties"];
                    $.each(obj, function(i, property) {
                        $.each(property["listings"], function(j, listing) {
                            console.log(listing["list_date"]);
                            var formattedListingDate = '';
                            var diffDays = '';
                            if(listing["list_date"] != undefined || listing["list_date"] != null){
                                var listingDate = new Date(listing["list_date"]);
                                var formattedListingDate = (listingDate.getMonth()+1)+"/"+listingDate.getDate()+"/"+listingDate.getFullYear();
                                var timeDiff = Math.abs(today.getTime() - listingDate.getTime());
                                var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24)); 
                            }
                            
                            var price = "$"+listing["price"].toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
                            if(price.endsWith(".00")){
                                price = price.slice(0, -3);
                            }
                            var tr1 = "<tr>";
                            var td1 = "<td style='font-size: 15px;'><a target='_blank' href="+listing["web_url"]+">"+listing["mls_id"]+"<a/></td>"
                            var td2 = "<td style='font-size: 15px;'>"+price+"</td>"
                            var td3 = "<td style='font-size: 15px;'>"+listing["address"]["line"]+", "+listing["address"]["city"]+", "+listing["address"]["state_code"]+" "+listing["address"]["postal_code"]+"</td>"
                            var td4 = "<td style='font-size: 15px;'>"+listing["photo_count"]+"</td>"
                            var td5 = "<td style='font-size: 15px;'>"+diffDays+"</td>"
                            var td6 = "<td style='font-size: 15px;'>"+formattedListingDate+"</td>"
                            var td7 = "<td style='font-size: 15px;'>"+listing["mls"]["abbreviation"]+"</td>"
                            var tr2 = "</tr>"
                            $('#listingTable tbody').append(tr1+td1+td2+td3+td4+td5+td6+td7+tr2);
                        });
                    });
                    $('#listingTable td').each(function () {
                        if($(this).html().includes("undefined")){
                            $(this).html($(this).html().replace("undefined",""));
                        }
                    });
                    setTimeout(function(){ 
                        $('#listingTable').DataTable();
                        // add lightning class to search filter field with some bottom margin..  
                        $('div.dataTables_filter input').addClass('slds-input');
                        $('div.dataTables_filter input').css("marginBottom", "10px");
                    }, 50); 
                } catch(e){
                    console.log("exception"+e);
                }
               
            }
        });
        $A.enqueueAction(action);
    }
})