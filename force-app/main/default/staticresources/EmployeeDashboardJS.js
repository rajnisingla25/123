   function displayAlert(alert, type, message) {
       $('.alertdiv').html('<div class="alert alert-dismissable alert-fixed alert-' + alert + '" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><i class="pi pi-ios-close-empty"></i></button><span class="mar-right-md">' + type + '</span>' + message + '</div>');
       setTimeout(function() {
           $('.alertdiv').html('');
       }, 5000);
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

   function addError(errorType, thisElement) {
       $("#" + errorType + "-error", thisElement).removeClass('hidden');
       $("#" + errorType + "-error", thisElement).addClass('help-block');
       $(thisElement).addClass('has-error');
   }

   function removeValidationError(errorType, thisElement) {
       $("#" + errorType + "-error", thisElement).addClass('hidden');
       $("#" + errorType + "-error", thisElement).removeClass('help-block');
       $(thisElement).removeClass('has-error');
   }

   function toggleCheckbox(thisElement) {
       if (thisElement.prop('checked')) {
           thisElement.prop('checked', false);
       } else {
           thisElement.prop('checked', true);
       }
   }

   function displayError(message){
       $('.error-div').html("<span style='color: red'>Error: </span>"+message);
   }

   function removeError(){
       $('.error-div').html("");
   }