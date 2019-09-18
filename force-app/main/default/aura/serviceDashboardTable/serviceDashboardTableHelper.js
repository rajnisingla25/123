({
	fetchcaseinfo: function (component, typeofissue) {
		console.log('typeofissue-->' + typeofissue);
		var action = component.get('c.fetchcaseInfo');
		action.setParams({
			message: typeofissue
		});
		action.setCallback(this, function (response) {
			//store state of response
			var state = response.getState();
			console.log('state-->' + state);
			if (state === "SUCCESS") {
				//set response value in lstOpp attribute on component.
				// component.set('v.lstOpp', response.getReturnValue());
				//     console.log(response.getReturnValue());
				$('#tableId').DataTable().destroy();
				var acctTable = $('#tableId').DataTable({
					"data": response.getReturnValue(),
					"columns": [{
							"class": 'details-control',
							"orderable": false,
							"data": null,
							"defaultContent": '',
							width: "8%"
						},
                        {
							"data": "CaseNumber",
							"defaultContent": ''
						},
						{
							"data": "Type",
							"defaultContent": ''
						},
						{
							"data": "Area__c",
							"defaultContent": ''
						},
						{
							"data": "Sub_Area__c",
							"defaultContent": ''
						},
						{
							"data": "Subject",
							"defaultContent": ''
						},
						{
							"data": "Child_cases__c",
							"defaultContent": ''
						},
						{
							"data": "Status",
							"defaultContent": ''
						},
						{
							"data": "Case_Age__c",
							"defaultContent": ''
						},
                        {
							"data": "Date_of_Last_Added_Child_Case__c",
							"defaultContent": ''
						},

					],
					order: [
                        [9, 'desc'],
                    	[8, 'asc'],
                    	[6, 'desc']
					],
                    "columnDefs": [
                        { "orderSequence": [ "desc" ], "targets": [ 9 ] },
                        { "orderSequence": [ "desc" ], "targets": [ 8 ] },
                        { "orderSequence": [ "desc" ], "targets": [ 6 ] }
                      ]  
				});

				$("table tbody tr").removeClass("odd even");
				$("table tbody tr:visible:odd").addClass("odd");
				$("table tbody tr:visible:even").addClass("even");

				$(document).ready(function () {
					$('#tableId tbody').off('click', 'td.details-control');
					$('#tableId tbody').on('click', 'td.details-control', function () {
						var tr = $(this).closest('tr');
						var row = acctTable.row(tr);
						if (row.child.isShown()) {
							// This row is already open - close it
							row.child.hide();
							tr.removeClass('shown');
							tr.removeClass('showna');
						} else {
							// Open this row
							console.log(row.data());
							var d = row.data();
							// var x = window.location.href;
							// var baseurl = x.substring(0, 45);
							var staticLabel = $A.get("$Label.c.staticLabel");
							console.log(staticLabel + '/' + d.Id);
                            var tableChildData = '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;width:50%;">' +
								//'<thead><tr><th>Type</th><th>Status</th></tr></thead><tbody>';
								'<th>Case Details:</th>' +
								'<tr>' +
								'<td>Case:</td>' +
								'<td>' + '<a href="' + staticLabel + '/' + d.Id + '" target="_blank">' + 'Go To Case'+ '</a>' + '</td>' +
								'</tr>' +
								'<tr>' +
								'<td>Sub Status:</td>' +
								'<td>' + ((d.SubStatus__c != null && d.SubStatus__c != '' && d.SubStatus__c != undefined) ? d.SubStatus__c : '') + '</td>' +
								'</tr>' +
								'<tr>' +
								'<td>Date Opened:</td>' +
								'<td>' + new Date(d.CreatedDate).toISOString().substring(0, 10) + '</td>' +
								'</tr>' +
								'<tr>' +
								'<td>Date of Last Added Child:</td>' +
								'<td>' + ((d.Date_of_Last_Added_Child_Case__c != null && d.Date_of_Last_Added_Child_Case__c != '' && d.Date_of_Last_Added_Child_Case__c != undefined) ? d.Date_of_Last_Added_Child_Case__c : '') + '</td>' +
								'</tr>' +
								'<tr>' +
								'<td>JIRA #:</td>' +
								'<td>' + ((d.JiraCaseNumber__c != null && d.JiraCaseNumber__c != '' && d.JiraCaseNumber__c != undefined) ? d.JiraCaseNumber__c : '') + '</td>' +
								'</tr>' +
								'<tr>' +
                                '<td >Description:</td>' +
                                '<td style="white-space:normal;max-width:450px;"><div style="word-break:break-all;width:400px;">' + ((d.Description != null && d.Description != '' && d.Description != undefined) ? d.Description : '') + '</div></td>' +
								'</tr>';

							tableChildData = tableChildData + '</tbody></table>';
							row.child(tableChildData).show();
							tr.addClass('shown');
							tr.addClass('showna');
						}
						$("#tableId tr:even").css("background-color", "#F4F4F8");
						$("#tableId tr:odd").css("background-color", "#EFF1F1");
						console.log($('.shown').css("background-color", "#bbc174"));
                        
					});
				});
				// add lightning class to search filter field with some bottom margin..  
				$('div.dataTables_filter input').addClass('slds-input');
				$('div.dataTables_filter input').css("marginBottom", "10px");
			}
		});
		$A.enqueueAction(action);
	},
	formatContacts: function (component, record) {
		var table = '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">' +
			//'<thead><tr><th>Type</th><th>Status</th></tr></thead><tbody>';
			'<tr>' +
			'<td>Case Number:</td>' +
			'<td>' + 'd.name' + '</td>' +
			'</tr>' +
			'<tr>' +
			'<td>Sub Status:</td>' +
			'<td>' + 'd.extn' + '</td>' +
			'</tr>' +
			'<tr>' +
			'<td>Date Opened:</td>' +
			'<td>' + 'd.extn' + '</td>' +
			'</tr>' +
			'<tr>' +
			'<td>Date of Last Added Child:</td>' +
			'<td>' + 'd.extn' + '</td>' +
			'</tr>' +
			'<tr>' +
			'<td>JIRA #:</td>' +
			'<td>And any further details here (images etc)...</td>' +
			'</tr>' +
			'<tr>' +
			'<td>Description:</td>' +
			'<td>' + 'd.extn' + '</td>' +
			'</tr>';
		records.forEach(function (record) {
			table = table + '<tr><td>' + 'Type' + '</td><td>' + 'Status' + '</td></tr>';
		});
		table = table + '</tbody></table>';
		return table;
	}
})