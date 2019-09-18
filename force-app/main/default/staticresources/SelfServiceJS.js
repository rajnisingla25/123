var states = ["Alabama","Alaska","American Samoa","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","District Of Columbia","Federated States Of Micronesia","Florida","Georgia","Guam","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Marshall Islands","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Northern Mariana Islands","Ohio","Oklahoma","Oregon","Palau","Pennsylvania","Puerto Rico","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virgin Islands","Virginia","Washington","West Virginia","Wisconsin","Wyoming"];
var monthName = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
var monthsWithInvoices = [];
var label = "";
var inventoryproducts = ['COBROKE', 'LOCALEXPERT','LOCALEXPERTCITY'];
var licenseTierProd = ['REESIO','TOPCRM','TOPMRKSNP','TOPWEB','TOPWEBFEE','FIVESTREET','BROKERMARKETING'];
var billingMap = new Map([
    ['Monthly', 'monthly'],
    ['Annual', 'yearly'],
    ['Bi-Annual', '6 months'],
    ['Quarterly', '3 months']
]);
var productNameMap = new Map([
    ['COBROKE', 'Connections<sup>SM</sup> Plus'],
    ['LOCALEXPERT', 'Local Expert Zip Ad<sup>SM</sup>'],
    ['LOCALEXPERTCITY', 'Local Expert City Ad<sup>SM</sup>'],
    ['TOPCRM', 'Top Producer® CRM'],
    ['ADVANTAGE', 'Advantage<sup>SM</sup> Pro'],
    ['TOPMRKSNP', 'Market Snapshot® Reports'],
    ['TOPWEB', 'Top Producer® Websites'],
    ['FIVESTREET', 'FiveStreet'],
    ['TOPIDX', 'Top Producer® IDX'],
    ['BROKERMARKETING', 'Broker Marketing Solutions']
]);
var anchorProductNameMap = new Map([
    ['COBROKE', 'connections-plus'],
    ['LOCALEXPERT', 'local-expert'],
    ['LOCALEXPERTCITY', 'local-expert-city'],
    ['COBROKEBMS', 'connections-plus-bms'],
    ['LOCALEXPERTBMS', 'local-expert-bms'],
    ['LOCALEXPERTCITYBMS', 'local-expert-city-bms'],
    ['TOPCRM', 'top-producer-crm'],
    ['ADVANTAGE', 'advantage-pro'],
    ['TOPMRKSNP', 'market-snapshot-reports'],
    ['TOPWEB', 'top-producer-websites'],
    ['FIVESTREET', 'fivestreet'],
    ['TOPIDX', 'top-producer-idx'],
    ['BROKERMARKETING', 'broker-marketing-solutions']
]);
var productDescriptionMap = new Map([
    ['COBROKE', 'A lead generation and conversion system to connect agents with serious buyers.'],
    ['LOCALEXPERT', 'Position yourself as the local expert with targeted branded ads.'],
    ['LOCALEXPERTCITY', 'Position yourself as the local expert with targeted branded ads.'],
    ['TOPCRM', 'Easily manage your sales pipeline from initial contact to closing and beyond.'],
    ['ADVANTAGE', 'Elevate your brand presence and get all leads delivered directly to your inbox.'],
    ['TOPMRKSNP', 'Real-time real estate market reports to help you stay top-of-mind.'],
    ['TOPWEB', 'Help your brand shine online with a beautiful, mobile-responsive real estate website.'],
    ['FIVESTREET', 'Simple features help you close deals.'],
    ['TOPIDX', 'MLS listings on your Top Producer® website.'],
    ['BROKERMARKETING', 'Specialized product package for brokers']
]);
var productLinkMap = new Map([
    ['COBROKE', 'https://marketing.realtor.com/connections-plus'],
    ['LOCALEXPERT', 'https://marketing.realtor.com/local-expert'],
    ['LOCALEXPERTCITY', 'https://marketing.realtor.com/local-expert'],
    ['TOPCRM', 'https://marketing.realtor.com/generate-repeat-referral-business'],
    ['ADVANTAGE', 'https://marketing.realtor.com/advantage-pro'],
    ['TOPMRKSNP', ' https://marketing.realtor.com/market-snapshot'],
    ['TOPWEB', ' https://marketing.realtor.com/top-producer-websites'],
    ['FIVESTREET', 'https://www.fivestreet.com/'],
    ['TOPIDX', ' https://marketing.realtor.com/top-producer-websites'],
    ['BROKERMARKETING', '']
]);

var lEProductType = new Map([
    ["SOV30", '30% Share of Market'],
    ["SOV20", '20% Share of Market'],
    ["SOV50", '50% Share of Market']
])
var totalCountMap = {};
var currentCountMap = new Map();
var invProductMarketMap = new Map();
var nonInvProductMap = new Map();
var marketPaginationLimit = 5;

/**
 * BEGIN: Common helper functions
 **/
function displayAlert(alert, type, message) {
   $('.alertdiv').html('<div class="alert alert-dismissable alert-fixed alert-' + alert + '" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><i class="pi pi-ios-close-empty"></i></button><span class="mar-right-md">' + type + '</span>' + message + '</div>');
   setTimeout(function() {
       $('.alertdiv').html('');
   }, 5000);
}

function displayGenericError(){
    $('#error-div').html('Something went wrong.');
}

function removeGenericError(){
    $('#error-div').html('');
}

function removeAlert(){
   $('.alertdiv').html('');
}
var showSpinner = function(args) {
   // Check parameters
   if (args === undefined || typeof args === 'string') {
       args = {
           container: (args === undefined) ? 'body' : args
       };
   }
   args.timeout = args.timeout || 330; // Default delay is 1/3 of a second
   args.handler = null;
   args.container = (typeof args.container === 'string') ? $(args.container) : args.container;
   args.css = args.css || '';
   args.size = args.size || 'large'; // small: 'sm' - medium: '' - large: 'lg'
   args.content = args.content || '';
   var size = '';
   if (args.size === 'small') {
       size = '-sm';
   } else if (args.size === 'large') {
       size = '-lg';
   }
   // Check if container is not a body and add class for positioning
   if (!args.container.is('body')) {
       args.css += ' pos-absolute';
   }
   var content = ['<div class="load-spinner-wrapper ', args.css, '"><div class="pos-absolute absolute-centering"><div class="load-spinner', size, ' mar-top-none mar-bottom-none"></div>' + args.content + '</div></div>'].join('');
   // Check for delay
   if (args.timeout > 0) {
       args.handler = window.setTimeout(function() {
           // Display with delay
           args.container.append(content);
           args.container.addClass('noscroll');
       }, args.timeout);
   } else {
       // Display immediately
       args.container.append(content);
       args.container.addClass('noscroll');
   }
   // Cache the last parameter so we can call hide without passing a parameter
   _args = args;
   // Return parameters
   return args;
};

var hideSpinner = function(args) {
       args = args || _args;
       // Stop the countdown
       if (args) {
           if (args.handler !== null) {
               window.clearTimeout(args.handler);
               args.handler = null;
           }
           args.container = (typeof args.container === 'string') ? $(args.container) : args.container;
           // Remove dom elements
           args.container.find('.load-spinner-wrapper').remove();
           args.container.removeClass('noscroll');
       } else if (console) {
           console.error('Parameters not specified for closing spinner');
       }
   };

var showPanelSpinner = function(){
    $(".panel-spinner").html('<div class="d-flex justify-content-center mar-md-vh"><div class="load-spinner-lg"  role="status"><span class="sr-only">Loading...</span></div></div>');
};

var hidePanelSpinner = function(){
    $(".panel-spinner").empty();
};

function formatMoney(amount) {
  try {
      decimalCount = 2;
      decimal = "."
      thousands = ","
    decimalCount = Math.abs(decimalCount);
    decimalCount = isNaN(decimalCount) ? 2 : decimalCount;

    const negativeSign = amount < 0 ? "-" : "";

    let i = parseInt(amount = Math.abs(Number(amount) || 0).toFixed(decimalCount)).toString();
    let j = (i.length > 3) ? i.length % 3 : 0;

    return negativeSign + (j ? i.substr(0, j) + thousands : '') + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousands) + (decimalCount ? decimal + Math.abs(amount - i).toFixed(decimalCount).slice(2) : "");
  } catch (e) {
    console.log(e)
    return amount;
  }
}

// END: Common helper functions

/*******
 * BEGIN: LCM-292 Statements & Invoices 
 *******/
function populateDateRangeFilter() {
    $("#date-range-filter").empty();
    if(localStorage.getItem('filterValue')) { 
        var d = new Date();
        d.setFullYear(d.getFullYear() - 1);
        var selected = localStorage.getItem('filterValue') == 'Last 12 Months' ? "selected='selected'" : '';
        $("#date-range-filter").append("<option " + selected + " value='Last 12 Months'>Last 12 Months</option>");
        while (d.getFullYear() >= 2017) {
            var selected = localStorage.getItem('filterValue') == d.getFullYear() ? "selected='selected'" : '';
            $("#date-range-filter").append("<option " + selected + " value=" + d.getFullYear() + ">" + d.getFullYear() + "</option>");
            d.setFullYear(d.getFullYear() - 1);
        }
    } else {
        var d = new Date();
        d.setFullYear(d.getFullYear() - 1);
        localStorage.setItem('filterValue', 'Last 12 Months');
        $("#date-range-filter").append("<option selected='selected' value='Last 12 Months'>Last 12 Months</option>");
        while (d.getFullYear() >= 2017) {
    	  $("#date-range-filter").append("<option value=" + d.getFullYear() + ">" + d.getFullYear() + "</option>");
    		d.setFullYear(d.getFullYear() - 1);
    	}
    }
	
}

function populateMonthsWithInvoices(result) {
    for(var i=0; i < Object.keys(result).length; i++){
        monthsWithInvoices.push(monthName[result[i]["Month"] - 1] + ' '+ result[i]["Year"]);
        if(monthsWithInvoices.indexOf('Year ' + result[i]["Year"]) < 0) {
            monthsWithInvoices.push('Year ' + result[i]["Year"]);
        }
    }
}
	        
function emptyStatementList() {
	$('.statement-list').empty();
}
function statementRow(linkToStatement, displayName) {
    if (screen.width < 768) {
       return '<strong><li class="list-group-item"><a rel="external" class="text-gray-darker" data-ajax="false" href="' + label + '/SelfServiceStatementsInvoicesDetails?title=' + displayName + '&' + linkToStatement.split('?')[1] + '">' + displayName + '<span class="pi pi-angle-right pull-right text-gray-base"></span></a></li></strong>';
    } else {
       return '<li class="list-group-item"><a data-ajax="false" rel="external" href="' + label + '/SelfServiceStatementsInvoicesDetails?title=' + displayName + '&' + linkToStatement.split('?')[1] + '" data-actualurl="" class="btn btn-link no-padding" data-omtag="statements_view">' + displayName + '</a><a href="' + linkToStatement + '" class="btn pull-right text-gray no-padding" target="_blank" data-omtag="statements_download" download="AccountStatement"> Download as PDF </a></li>' 
    }
}
function getLinkToStatement(endDate, startDate) {
	var accId = $("#sfdc-account-id").data('sfdc-id');
	return label + '/accountstatement?endDate=' + endDate + ' 23:59:59&amp;id=' + accId + '&amp;startDate=' + startDate + '-01 00:00:00';
}
function appendStatementRowToList(endDate, startDate, displayName) {
	var linkToStatement = getLinkToStatement(endDate, startDate);
    $('.statement-list').append(statementRow(linkToStatement, displayName));
}
function getMonthlyList(year, i) {
	var endDate = year + '-' + (i+1) + '-' + new Date(year, i+1, 0).getDate();
	var startDate = year + '-' + (i+1);
	var displayName = monthName[i] + ' ' + year;
	if(monthsWithInvoices.indexOf(displayName) >= 0) {
	    appendStatementRowToList(endDate, startDate, displayName);
	}
}
function populateLast12MonthList() {
    var d = new Date();
    d.setMonth(d.getMonth() - 1);
    emptyStatementList();
    for (i=0; i<12; i++) {
    	var endDate = d.getFullYear() + '-' + (d.getMonth()+ 1) + '-' + new Date(d.getFullYear(), d.getMonth()+1, 0).getDate();
    	var startDate = d.getFullYear() + '-' + (d.getMonth()+ 1);
    	var displayName = monthName[d.getMonth()] + ' ' + d.getFullYear();
    	if(monthsWithInvoices.indexOf(displayName) >= 0) {
    	    appendStatementRowToList(endDate, startDate, displayName);
    	}
        d.setMonth(d.getMonth() - 1);
    }
}
function populateYearlyMonthList(year) {
    emptyStatementList();
    populateYearlyList(year);
    for (i=0; i<12; i++) {
    	getMonthlyList(year, i);
    }
}
function populate2017List(year) {
	emptyStatementList();
    populateYear2017List();
    for (i=8; i<12; i++) {
    	getMonthlyList(year, i);
    }
}
function populateYear2017List() {
	var endDate = '2017-12-31';
	var startDate = '2017-08-01';
	var displayName = 'Year 2017';
	if(monthsWithInvoices.indexOf(displayName) >= 0) {
	    appendStatementRowToList(endDate, startDate, displayName);
	}
}
function populateYearlyList(year) {
	var endDate = year + '-12-31';
	var startDate = year + '-01-01';
	var displayName = 'Year ' + year;
	if(monthsWithInvoices.indexOf(displayName) >= 0) {
	    appendStatementRowToList(endDate, startDate, displayName);
	}
}

function addEmptyLayoutIfNoInvoices() {
    if($(".statement-list").has("li").length === 0) {
        $('.empty-invoice-div').removeClass('hidden');
        $('.empty-invoice-div').addClass('show');
    } else {
      $('.empty-invoice-div').addClass('hidden');  
    }
}
function updateStatementList(selectedText) {
    if(selectedText === 'Last 12 Months') {
    	populateLast12MonthList();
    } else if(selectedText === '2017') {
        populate2017List(selectedText);
    } else { // eg : 2018
    	populateYearlyMonthList(selectedText);
    }
}
function changeListView() {
    var selectedText = $("#date-range-filter").find("option:selected").text();
    localStorage.setItem('filterValue', selectedText);
    updateStatementList(selectedText);
    addEmptyLayoutIfNoInvoices();
}
function initStatementsPage(statementLabel, resultHash) {
    label = statementLabel;
    populateMonthsWithInvoices(resultHash);
    if(localStorage.getItem('filterValue')) { 
        updateStatementList(localStorage.getItem('filterValue'));
    }else {
        populateLast12MonthList();
        localStorage.setItem('filterValue', 'Last 12 Months');
    }
    addEmptyLayoutIfNoInvoices();
}   

// END: LCM-292 Statements & Invoices End

/*********
 * BEGIN: LCM-293 Credit Card 
 *********/
function getCreditCardDetails(src, updateHeader) {
    var id = $(".card-id").data('cardId');
    SelfServiceController.getCCDetailsById(id, function(result, event) {
        if(event.status && result !== null && result !== undefined){
            var cardNumber = result['maskNumber'].split('*').pop();
            var cardHolderName = result['cardHolderName'];
            var cardExpirationDate = result['expirationDate'];
            var panelTitle = result['cardType']  + ' ending in ' + cardNumber;
            var address1 = result['CCAddress1'] ? result['CCAddress1'] + '<br />' : '';
            var address2 = result['CCAddress2'] ? result['CCAddress2'] + '<br />' : '';
            var city = result['CCCity'] ? result['CCCity'] + ',' : '';
            var state = result['CCState'] ? result['CCState'] : '';
            var zip = result['CCZipCode'] ? result['CCZipCode'] : '';
            var billingAddress = address1 + address2 + city + state + zip
            $(".panel-title").html(panelTitle);
            if(updateHeader) {
                $(".title-section-header").append('<div class="visible-xs title-header-xs"><strong class="mar-left-md">' + panelTitle + '</strong></div>');
            }
            $(".zuoraPaymentMethodId").val(result['zPmId']);
            $(".paymentMethodId").val(result['pmId']);
            if (result['splitPercent'] == 100) {
                defaultPayment = '<h5 class="mar-bottom-xl default-payment display-inline-block">Default card for payment</h5><span class="pi pi-check"></span>'
            } else {
                defaultPayment = '<h5 class="mar-bottom-xl default-payment display-inline-block">Split Percent : ' + result['splitPercent'] + '% </h5>';
            }
            if (billingAddress != '') {
                var addressTemplate = '<h5 class="detail-fields">Billing Address</h5>' +
                                       '<address>' +
                                        address1 + 
                                        address2 +
                                        city + state + '<br />' +
                                        zip + '<br />\
                                        </address>';
            } else {
                var addressTemplate = ''
            }
            var template = '<div>' + defaultPayment + '<h5 class="detail-fields">Card Number</h5>\
                                <p class="mar-bottom-md display-inline-block">**** **** **** ' + cardNumber + '</p>\
                                <div class="card-img display-inline-block">\
                                    <img id="credit-card-icon" src=' + src + '>\
                                </div>\
                                <h5 class="detail-fields">Name on Card</h5>\
                                <p class="mar-bottom-md">' + cardHolderName + '</p>\
                                <h5 class="detail-fields">Expiry Date</h5>\
                                <p class="mar-bottom-md">' + cardExpirationDate + '</p>'
                                + addressTemplate +  
                           '</div>';
            $(".credit-card-details").empty();
            $(".credit-card-details").append(template);
            var editClass = ($(window).width() >= 768) ? 'btn btn-primary edit-card' : 'btn btn-link edit-card';
            var editButton = '<button type="button" class="' + editClass + '" data-toggle="modal" data-target="#enter-password-modal">Edit</button>';
            $(".credit-card-actions").empty();
            $(".credit-card-actions").append(editButton);
        }
    });
}
function isCardValid() {
    var requiredField = 'This field is required.'
    var isValid = true;
    if($("#input-creditCardExpirationMonth").val() == '' || $("#input-creditCardExpirationYear").val() == '') {
        $('#error-creditCardExpirationMonth').html(requiredField);
        isValid = false;
    }
    if($("#input-creditCardHolderName").val() == '') {
        $('#error-creditCardHolderName').html(requiredField);
        isValid = false;
    }
    if($("#input-creditCardPostalCode").val() == '') {
        $('#error-creditCardPostalCode').html(requiredField);
        isValid = false;
    }
    if($("#input-creditCardCity").val() == '') {
        $('#error-creditCardCity').html(requiredField);
        isValid = false;
    }
    if($("#input-creditCardState").val() == '') {
        $('#error-creditCardState').html(requiredField);
        isValid = false;
    }
    if($("#input-creditCardAddress1").val() == '') {
        $('#error-creditCardAddress1').html(requiredField);
        isValid = false;
    }
    return isValid;
}
function updateCreditCardDetails(cardId, cardImgLink) {
    var pmId = $(".paymentMethodId").val();
    var zPmId = $(".zuoraPaymentMethodId").val();
    var expirationDate = $("#input-creditCardExpirationMonth").val() + "/" + $("#input-creditCardExpirationYear").val();
    var cardholderName = $("#input-creditCardHolderName").val();
    var zipCode = $("#input-creditCardPostalCode").val();
    var city = $("#input-creditCardCity").val();
    var state = $("#input-creditCardState").val();
    var address1 = $("#input-creditCardAddress1").val();
    var address2 = $("#input-creditCardAddress2").val();
    var country = "US";
    SelfServiceController.updateCCDetails(cardId, pmId, zPmId, expirationDate, cardholderName, zipCode, city, state, country, address1, address2, function(result, event) {
        hideSpinner();
        $(".updateCardDetails").prop("disabled", false);
        if(result == true) {
            displayAlert("success", "Success", "Your credit card has been updated");
            $(".error-field").empty();
            $('#edit-card').modal('hide');
            getCreditCardDetails(cardImgLink, false);
        } else {
            displayAlert("danger", "Error", "Sorry, we weren't able to update your credit card. Try again, and if the problem persists, give us a call at (877) 309-3151.");
        }
    }); 
}
function editCardDetails(cardImgLink) {
    if(isCardValid()) {
        showSpinner();
        $(".updateCardDetails").attr("disabled", "disabled");
        var cardId = $(".card-id").data('cardId');
        updateCreditCardDetails(cardId, cardImgLink);
    }
}

 // LCM-403, LCM-376
 function attachHandlersCCDetailPage() {
     $("#edit-credit-card-password").on('keyup', function(event) {
         var password = $(this).val();
         if (password === '' || password === null) {
             $('#verify-password-btn').attr("disabled", "disabled");
         } else {
             $('#verify-password-btn').removeAttr('disabled');
         }
     });

     $("#edit-credit-card-password").on("focusout", function() {
         $("#enter-password-modal .help-block").addClass("focus-visible");
     });
     $("#edit-credit-card-password").on("focusin", function() {
         $("#enter-password-modal .help-block").removeClass("focus-visible");
     });
      //LCM-403: handle enter click
     $("#password-verify-form").submit(function(event){
         event.preventDefault();
         showSpinner();
         var password = $("#edit-credit-card-password").val();
         if (password !== '' && password !== null) {
             verifyPassword(password, "edit");
         }
     });
 }
 
 //LCM-376, LCM-403
 function attachHandlersCCPage() {
     $("#add-credit-card-password").on('keyup', function(event) {
         var password = $(this).val();
         if (password === '' || password === null) {
             $('#verify-password-btn').attr("disabled", "disabled");
         } else {
             $('#verify-password-btn').removeAttr('disabled');
         }
     });

     $("#add-credit-card-password").on("focusout", function() {
         $("#enter-password-modal .help-block").addClass("focus-visible");
     });
     $("#add-credit-card-password").on("focusin", function() {
         $("#enter-password-modal .help-block").removeClass("focus-visible");
     });
     //LCM-403: handle enter click
     $("#password-verify-form").submit(function(event){
         event.preventDefault();
         showSpinner(); 
         var password = $("#add-credit-card-password").val();
         if (password !== '' && password !== null) {
             verifyPassword(password, "add");
         }
     });
 }
 
function verifyPassword(password, actionType) {
    SelfServiceController.verifyPassword($("#sfdc-account-id").data('advertiserId'), password, function(res, event) {
        var displayError = true;
        $("#" + actionType + "-credit-card-password").val('');
        $('#verify-password-btn').attr("disabled", "disabled");
        try {
            if (event.status && res !== null && res !== undefined) {
                var result = JSON.parse(res);
                if (result["data"] !== null && result["data"] !== undefined && result["data"]["success"] === 'true') {
                    $('#enter-password-modal').modal('hide');
                    if (actionType === 'edit') {
                        openEditModal();
                    } else if (actionType === 'add') {
                        updateCCIframeDisplay();//LCM-429
                        $('#add-card').modal('show');
                    }
                    displayError = false;
                    hideSpinner();
                } else if (result["RestFaultElement"] !== null && result["RestFaultElement"] !== undefined) {
                    var detail = JSON.parse(result["RestFaultElement"]["detail"]);
                    if (detail["error_data"]["msg"].includes("password you entered is incorrect")) {
                        displayError = false;
                        hideSpinner();
                        displayAlert("danger", "Error", "Sorry, please check your password. Try again, and if the problem persists, give us a call at (877) 309-3151.");
                    }
                }
            }
            hideSpinner();

        } catch (exception) {
             hideSpinner();
            console.log(exception);
        }
        if (displayError) {
            hideSpinner();
            if(actionType === 'edit'){
                displayAlert("danger", "Error", "Sorry, we weren't able to update your credit card. Try again, and if the problem persists, give us a call at (877) 309-3151.");
            } else {
                displayAlert("danger", "Error", "Sorry, we could not replace your card now. Try again, and if the problem persists, give us a call at (877) 309-3151.");
            }
        }
    }, {
        escape: false
    });

}
 
function openEditModal() {
    $('#enter-password-modal').modal('hide');
    $('#edit-card').modal('show');
    var id = $(".card-id").data('cardId');
    $("#input-creditCardExpirationMonth").empty();
    SelfServiceController.getCCDetailsById(id, function(result, event) {
        if(event.status && result !== null && result !== undefined){
            // Update values in Edit modal
            $(".credit-card-number").text(result['cardType'] + ' ending in ' + result['maskNumber'].split('*').pop());
            $("#input-creditCardHolderName").val(result['cardHolderName']);
            $("#input-creditCardAddress1").val(result['CCAddress1']);
            $("#input-creditCardAddress2").val(result['CCAddress2']);
            $("#input-creditCardCity").val(result['CCCity']);
            $("#input-creditCardPostalCode").val(result['CCZipCode']);
            
            // add expiration month dropdown to edit modal
            for(var i = 1; i <= 12; i++) {
                $("#input-creditCardExpirationMonth").append("<option value=" + i + ">" + i + "</option>");
            }
            $("#input-creditCardExpirationMonth").val(parseInt(result['expirationDate'].split("/")[0]));
            
            // add expiration year dropdown to edit modal
            var currentYear = new Date().getFullYear();
            var endYear = currentYear + 30;
            for(var i = currentYear; i <= endYear; i++) {
                $("#input-creditCardExpirationYear").append("<option value=" + i + ">" + i + "</option>");
            }
            $("#input-creditCardExpirationYear").val(result['expirationDate'].split("/")[1]);
            
            // add state dropdown to edit modal
            for(i = 0; i < states.length; i++) {
                 $("#input-creditCardState").append("<option value=" + states[i] + ">" + states[i] + "</option>");
            }
            $("#input-creditCardState").val(result['CCState']);
        }
    });
}     

// Callback function for Add CC  
function customProcessCallback(params) {

    var response = $jq.parseJSON(params);
    processCallback(params);
    console.log(response);
    if (response.success) {
        callbackSuccess();
    } else {
        callbackFailure();
    }
    if (processCallback) {
        processCallback(params);
    }
}

// END: LCM-293 Credit Card

/*****  BEGIN: LCM-320 My Products *****/
function getAllProducts(acctId) {
    removeGenericError();
    showPanelSpinner();
    SelfServiceController.getAllProducts(acctId, function(result, event) {
        if (event.status) {
            if(result === null){
                //LCM-417
                hidePanelSpinner();
                var emptyProdTemplate = $('#empty-product-template').html();
                Mustache.parse(emptyProdTemplate); // optional, speeds up future uses
                var rendered = Mustache.render(emptyProdTemplate, '');
                $('#product-summary-div').html(rendered);
                return false;
            }
            if(result !== null && result !== undefined){
                generateProductSummary(JSON.parse(result));
            } else {
                displayGenericError();
                hidePanelSpinner();
            }
        } else {
            displayGenericError();
            hidePanelSpinner();
            console.log(event);
        }
    }, {
        escape: false
    });
}

/** 
 * @desc Method to generate HTML for product summary section
 **/
function generateProductSummary(response) {
    var productSizetext = response["products-size"] + " products";
    if (response["products-size"] === 1) {
        productSizetext = "1 product";
    }
    var summaryView = {
        "products": [],
        "product-size": productSizetext,
        "totalCost": '0',
        "accountId": response["sfdc-account-id"]
    }
    var productSummary = response["product-summary"];
    var productSet = []; // Set of all products in sorted manner
    //LCM-411
    productsSorted = Object.keys(productSummary).sort(function(a,b){return productSummary[b]-productSummary[a]});
    var totalCost = 0;
    for (var i = 0; i < productsSorted.length; i++) {
        var product = productsSorted[i];
        productSet.push(product); 
        var list = summaryView["products"];
        var formattedPrice = formatMoney(productSummary[product]);
        totalCost += productSummary[product];
        var item = {
                "name": productNameMap.get(product),
                "price": formattedPrice,
                "anchorProductName": anchorProductNameMap.get(product),
                "comarDisplay": "none",
                "productCode": product
        };
        if (response["co-marketing-contribution"] != undefined && response["co-marketing-contribution"] != 0 && product === 'COBROKE') {
            totalCost -= response["co-marketing-contribution"];
            item["comarDisplay"] = "";
            item["comarPrice"]= formatMoney(response["co-marketing-contribution"]);
        }
        //LCM-441
        if(product == 'BROKERMARKETING'){
            var bmsList = [];
            // IF BMS add all bms product codes in summary
            for(var j = 0; j < response['bms-product-codes'].length; j++){
                var originalProductCode = response['bms-product-codes'][j];
                if(originalProductCode.endsWith("BMS")){
                    var pc = originalProductCode.slice(0, response['bms-product-codes'][j].length - 3);
                    if(inventoryproducts.includes(pc)){
                        originalProductCode = pc;
                    }        
                }
               var bmsItem = {
                   "bmsProductName":  productNameMap.get(originalProductCode),
                   "anchorProductName": anchorProductNameMap.get(response['bms-product-codes'][j])
               }
               bmsList.push(bmsItem);
           }
           item["bmsProducts"] = bmsList;
        }
        list.push(item);

        summaryView["products"] = list;
    }
    summaryView["totalCost"] = formatMoney(totalCost);
    var summaryTemplate = $('#summary-template').html();
    Mustache.parse(summaryTemplate); // optional, speeds up future uses
    var rendered = Mustache.render(summaryTemplate, summaryView);
    $('#product-summary-div').html(rendered);
    totalCountMap = response["product-count"];
    productSet = productSet.concat(response['bms-product-codes']);;
    generateProductDetails(response["all-products"], productSet, response['bms-product-codes'], response['bms-price'], response['bms-billing-period']);
    finalActions();
    getCityStateData(response["zipcode-set"]);
}


/** 
 * @desc Method to generate HTML panels for each product
 **/
function generateProductDetails(productDetail, productSet, bmsProductSet, bmsPrice, bmsBillingPeriod) {
    var productDetailsView = {
        "allProducts": [],
    }
    var bmsProductDetailsView = {
        "allProducts": [],
    }
    for (var i = 0; i < productDetail.length; i++) {
        var productCode = productDetail[i]['Product_Code__c'];
        getAssetDetails(productDetail[i]);
    }
    var productDetailsTemplate = $('#product-detail-template').html();
        Mustache.parse(productDetailsTemplate); // optional, speeds up future uses

    // For each product generate the panel
    productSet.forEach(function(value) {
        if(value != 'BROKERMARKETING'){
            var list = productDetailsView["allProducts"];
            var bmsList = bmsProductDetailsView["allProducts"];
            var originalProductCode = value;
            if(value.endsWith("BMS")){
                var pc = value.slice(0, value.length - 3);
                if(inventoryproducts.includes(pc)){
                    originalProductCode = pc;
                }        
            }
            var newItem = {
                "productName": productNameMap.get(originalProductCode),
                "productCode": value,
                "anchorProductName": anchorProductNameMap.get(value),
                "description": productDescriptionMap.get(originalProductCode),
                "productLink": productLinkMap.get(originalProductCode)
            };
            if (invProductMarketMap.has(value)) {
                newItem["hasInventory"] = "";
                newItem["isNonInventory"] = "none";
                newItem["isBMS"] = '';
                if(originalProductCode !== value){
                    newItem["isBMSInventory"] = '';
                    var bmsInvCt = totalCountMap[value];
                    if(bmsInvCt === 1){
                        newItem["nonInvProdDetails"] = '1 Market';
                    } else {
                        newItem["nonInvProdDetails"] = bmsInvCt + ' Markets';
                    }
                    newItem["nonInvBilling"] = 'Bundle Pricing'; 
                } else {
                    newItem["isBMSInventory"] = 'none';
                }
            } else {
                newItem["hasInventory"] = "none";
                newItem["isNonInventory"] = "";
                var astDetails = nonInvProductMap.get(value);
                newItem["nonInvProdDetails"] = astDetails["marketDetail"];
                newItem["nonInvBilling"] = astDetails["billing"]; 
                newItem["nonInvExpiry"] = astDetails["expiryData"];
                newItem["isBMS"] = '';
                newItem["isBMSInventory"] = 'none';
            }
            if(!bmsProductSet.includes(value)){
                list.push(newItem);
                productDetailsView["allProducts"] = list;
            } else {
                bmsList.push(newItem);
                bmsProductDetailsView["allProducts"] = bmsList;
            }
        } else {//LCM-441
            var bmsMD = bmsProductSet.length.toString();
            if (bmsProductSet.length != 1) {
                bmsMD = bmsMD.concat(" Products");
            } else {
                bmsMD = bmsMD.concat(" Product")
            }
            var newItem = {
                "productName": productNameMap.get(value),
                "productCode": value,
                "anchorProductName": anchorProductNameMap.get(value),
                "description": productDescriptionMap.get(value),
                "hasInventory": "none",
                "isNonInventory": "",
                "nonInvProdDetails": bmsMD,
                "nonInvBilling": "$ " + formatMoney(bmsPrice) + " (" + billingMap.get(bmsBillingPeriod) + ")",
                "isBMS": "none",
                "isBMSInventory" : 'none'
            };
             var bmsSummaryView = {
                "allProducts": newItem
            }
            var bmsRendered = Mustache.render(productDetailsTemplate, bmsSummaryView);
            $('#bms-summary-div').html(bmsRendered);
        }
     
    });
    
    var rendered = Mustache.render(productDetailsTemplate, productDetailsView);
    $('#product-details-div').html(rendered);
    
    var bmsRendered = Mustache.render(productDetailsTemplate, bmsProductDetailsView);
    $('#bms-summary-div').append(bmsRendered);

    // Generate market list (Assets) panel for inventory products
    for (const [prodCode, markets] of invProductMarketMap.entries()) {
        var nextActiveStatus = "enabled";
        // Pagination
        if (currentCountMap.get(prodCode)["endCount"] === totalCountMap[prodCode]) {
            nextActiveStatus = "disabled";
        }
        var marketDetailsView = {
            "markets": markets,
            "totalCount": totalCountMap[prodCode],
            "startCount": currentCountMap.get(prodCode)["startCount"],
            "endCount": currentCountMap.get(prodCode)["endCount"],
            "productCode": prodCode,
            "prevActiveStatus": "disabled",
            "nextActiveStatus": nextActiveStatus
        }

        var marketDetailsTemplate = $('#market-detail-template').html();
        Mustache.parse(marketDetailsTemplate); // optional, speeds up future uses
        var rendered = Mustache.render(marketDetailsTemplate, marketDetailsView);
        $("#" + prodCode + "-product-details").html(rendered);

    }
}


/** 
 * @desc Method to generate market list/pricing details json for Mustache.JS template for each product
 **/
function getAssetDetails(marketInfo) {
    productCode = marketInfo['Product_Code__c'];
   
    var marketDetail = "";
    var expiryData = "";
    //LCM-433
    var mQuantity = marketInfo['Quantity__c'];
    if(licenseTierProd.includes(productCode) && marketInfo['License_Tier__c'] !== null && marketInfo['License_Tier__c'] !== undefined){
        mQuantity =  marketInfo['License_Tier__c'];
    }
    if (productCode === 'COBROKE') {
        // Market detail e.g: 1 Fast half slot - San Francisco, CA  |  Expires 9/30/19 
        marketDetail = mQuantity + " " +
            marketInfo['Lead_Type__c'];
        if (marketInfo['Product_Type__c'] == "Half") {
            marketDetail = marketDetail.concat(" Half")
        }
        if (mQuantity != 1) {
            marketDetail = marketDetail.concat(" slots");
        } else {
            marketDetail = marketDetail.concat(" slot")
        }
    } else if (productCode === 'LOCALEXPERT') {
        marketDetail = marketDetail.concat(lEProductType.get(marketInfo['Product_Type__c']));
    } else if (productCode === 'LOCALEXPERTCITY') {//CRM-6097
        marketDetail = marketDetail.concat(marketInfo['Quantity__c'] * 10 +'% Share of Market');
    } else {
         marketDetail = mQuantity.toString();
        if (mQuantity != 1) {
            marketDetail = marketDetail.concat(" Licenses");
        } else {
            marketDetail = marketDetail.concat(" License")
        }
    }
    if (marketInfo['End_Date__c'] !== null && marketInfo['End_Date__c'] !== undefined) {
        var endDate = new Date(marketInfo['End_Date__c']);
        //LCM-400
        var dt = marketInfo['End_Date__c'].split('-');
        var formattedDate = parseInt(dt[1], 10)+'/'+parseInt(dt[2], 10)+'/'+dt[0].substr(2);
        //var formattedDate = (endDate.getMonth()+1) + "/" + endDate.getDate() + "/" + endDate.getFullYear().toString().substr(-2);
        expiryData = expiryData.concat("Expires " + formattedDate);
    }
    // End Market Detail

    // Billing detail
    var formattedPrice = formatMoney(marketInfo['Extended_Net_Price__c']);
    var billing = "";
    //LCM-431
    if(marketInfo['Commerce_Group__c'] !== null && marketInfo['Commerce_Group__c'] === "Broker Marketing Solution"){
        billing = "Bundle Pricing";
    } else {
        billing = "$ " + formattedPrice + " (" + billingMap.get(marketInfo['Billing_Period__c']) + ")";
    }
    // End Billing detail
    if (inventoryproducts.includes(productCode)) {
        var mrec = {
                "zipcode": marketInfo['Market__c'],
                "marketDetail": marketDetail,
                "expiryData": expiryData,
                "billing": billing
        };
        var marketsList = [];
        if(marketInfo['Commerce_Group__c'] !== null && marketInfo['Commerce_Group__c'] === "Broker Marketing Solution"){
            productCode = productCode +'BMS';
        }
         if (!currentCountMap.has(productCode)) {
            currentCountMap.set(productCode, {
                "startCount": 1,
                "endCount": 1
            });
        } else {
            var ct = currentCountMap.get(productCode);
            ct["endCount"] += 1;
            currentCountMap.set(productCode, ct);
        }
        if (invProductMarketMap.has(productCode)) {
            marketsList = invProductMarketMap.get(productCode);
            marketsList.push(mrec);
        } else {
            marketsList = [mrec];
        }
         invProductMarketMap.set(productCode, marketsList);
    } else {
        nonInvProductMap.set(productCode, {
            "marketDetail": marketDetail,
            "billing": billing,
            "expiryData": expiryData
        });
    }
}

/** 
 * @desc Method to get city and state data based on zip
 **/
function getCityStateData(zipcodeSet){
    SelfServiceController.getGeoParserData(zipcodeSet, function(result, event) {
        if (event.status && result !== null && result !== undefined) {
            for(var zip in result){
                $("."+zip+"-city-div").html(" - "+result[zip]);
            }
        }
    });
}

/** 
 * @desc Method will execute when product summary and details sections are built
 **/
function finalActions() {
    attachHandlersMyProducts();
    var template = $("#separately-billed-template").html();
    $("#bms-product-details-div").append(template);
    $("#COBROKE-product-details").addClass("border-bottom-grey");
    $("#COBROKEBMS-product-details").addClass("border-bottom-grey");
    $("#COBROKE-product-details").parent().append('<div class="slots-help-text text-muted"> <span class="pad-right-sm">What are slots</span> <span id="tooltip-0"><i class="pi pi-info-circle text-muted font-size-base" data-toggle="tooltip" data-container="body" data-placement="bottom" title="" data-html = true ></i></span></div>');
    $("#COBROKEBMS-product-details").parent().append('<div class="slots-help-text text-muted hidden" id="bms-slots-help"> <span class="pad-right-sm">What are slots</span> <span id="tooltip-0"><i class="pi pi-info-circle text-muted font-size-base" data-toggle="tooltip" data-container="body" data-placement="bottom" title="" data-html = true ></i></span></div>');

    $('[data-toggle="tooltip"]').tooltip({
        title: "<div class='text-left'><div style='font-weight: 300; '>- In <span style='font-weight:400;' >Full</span> slots, you can receive up to 40 buyer connections per year. <div class='mar-top-sm'>- In <span style='font-weight:400;' >Half</span > slots, you can receive up to 20 buyer connections per year. </div> <div class='mar-top-sm'>- In <span style='font-weight:400;' >Flex</span> slots, an inquiry is sent to only 1 agent. </div> <div class='mar-top-sm'>- In <span style='font-weight:400;' >Fast</span> slots, an inquiry is sent to 2 agents at the same time.</div></div></div>"
    });
    for(var i = 0; i < inventoryproducts.length; i++){
        $("#"+inventoryproducts[i]+"BMS-product-details, #"+inventoryproducts[i]+"BMS-sorting:parent").addClass("hidden");
        $("#"+inventoryproducts[i]+"BMS-product-details, #bms-slots-help").addClass("border-bottom-grey");
    }
    $(".sorting-option-div").each(function(i){
        var selectProdCode = $(this).find("select").data("product-code");
        if(!inventoryproducts.includes(selectProdCode)){
            $("#"+selectProdCode+"-sorting option[value='priceHighToLow']").remove();
            $("#"+selectProdCode+"-sorting option[value='priceLowToHigh']").remove();
            $("#"+selectProdCode+"-sorting option[value='endDateAscending']").attr("selected","selected");
        }
    });
    hidePanelSpinner();
    $('.selectpicker').selectpicker('render');
}

/** 
 * @desc Method to handle all events like button clicks
 **/
function attachHandlersMyProducts() {
        attachHandlersPagination();
        $(".market-sorting-filter").on("change", function(){
            showSpinner();
            getInvPaginationData($(this), false);
        });
        $(".toggle-markets-btn").on("vclick", function(event){
            var productCode = $(this).data("product-code");
            if($(this).data("status") === 'hidden'){
                 $("#"+productCode+"-product-details, #bms-slots-help").removeClass("hidden");
                 $("#"+productCode+"-sorting").parent().removeClass("hidden");
                 $(this).data("status", "displaying");
                 $(this).html("Hide Markets");
            } else {
                  $("#"+productCode+"-product-details,#bms-slots-help").addClass("hidden");
                  $("#"+productCode+"-sorting").parent().addClass("hidden");
                  $(this).data("status", "hidden");
                  $(this).html("Show Markets");
            }
        });
}
//CRM-5959
function getInvPaginationData($this, isPaginationBtn) {
    var start = 0;
    var end = 0;
    var productCode = $this.data("product-code");
    var offset = 0;
    var filter = "priceHighToLow";
    
    if(isPaginationBtn){
        start = $this.data("start-count");
        end = $this.data("end-count");
        offset = parseInt(end);
        if ($this.data("pagination") == "previous-link") {
            offset = parseInt(start) - marketPaginationLimit - 1;
        }
    }
    var isBMS = false;
    var originalProductCode = productCode;
    if (productCode.endsWith("BMS")) {
        isBMS = true;
        originalProductCode = productCode.slice(0, productCode.length - 3);
    }
    if(inventoryproducts.includes(originalProductCode)){
        filter =  $("#"+productCode+"-sorting").val();
    }
    SelfServiceController.getInvPaginationData($(
            "#sfdc-account-id").data("sfdc-id"), offset,
        marketPaginationLimit, originalProductCode, isBMS, filter,
        function(res, event) {
            if (event.status && res !== null && res !== undefined) {
                var result = JSON.parse(res);
                invProductMarketMap.delete(productCode);
                var allProducts = result["all-products"];
                for (var i = 0; i < allProducts.length; i++) {
                    getAssetDetails(allProducts[i]);
                }
                var newStart = offset + 1;
                var newEnd = offset + allProducts.length;
                var nextActiveStatus = "enabled";
                var prevActiveStatus = "enabled";
                if (newStart === 1) {
                    prevActiveStatus = "disabled";
                }
                if (newEnd === totalCountMap[productCode]) {
                    nextActiveStatus = "disabled";
                }
                var marketDetailsView = {
                    "markets": invProductMarketMap.get(productCode),
                    "totalCount": totalCountMap[productCode],
                    "startCount": newStart,
                    "endCount": newEnd,
                    "productCode": productCode,
                    "prevActiveStatus": prevActiveStatus,
                    "nextActiveStatus": nextActiveStatus
                }
                var marketDetailsTemplate = $('#market-detail-template').html();
                Mustache.parse(marketDetailsTemplate); // optional, speeds up future uses
                var rendered = Mustache.render(marketDetailsTemplate, marketDetailsView);
                $("#" + productCode + "-product-details").html(rendered);
                $("#" + productCode + "-product-details").removeClass("hidden");
                attachHandlersPagination();
                hideSpinner();
                getCityStateData(result["zipcode-set"]);
            } else {
                displayGenericError();
            }
            hideSpinner();
        }, {
            escape: false
        });
}

/** 
 * @desc Method to handle all events like button clicks
 **/
function attachHandlersPagination() {
    $(".pagination .enabled .market-pagination-link").on("vclick", function(event) {
            showSpinner();
            getInvPaginationData($(this), true);
            
    });
}

// END: My Products
