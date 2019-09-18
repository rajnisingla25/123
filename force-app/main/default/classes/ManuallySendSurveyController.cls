//
// (c) 2015 Appirio, Inc.
//
// Web-Service Class Name: ManuallySendSurveyController
// Description: This web-service is used to manually send survey of cases to third party system via workflow outbound messages.
//
// 14th May 2015		Hemendra Singh Bhati		Original (Task # T-381056)
//
global class ManuallySendSurveyController {
  /*
  @method      : sendSurvey
  @description : This web-service is used to manually send survey of cases to third party system via workflow outbound messages.
  @params      : Id caseId
  @returns     : String status.
  */
	webservice static String sendSurvey(Id caseId, String caseType) {
		try {
			if(String.isBlank(caseId)) {
				return 'Error: Invalid request. Case ID is missing. Please contact system administrator.';
			}
			else if(String.isBlank(caseType)) {
				return 'Error: Invalid request. The case type is not set for the requested case. Please set the case type and try once again.';
			}

			system.debug('TRACE: ManuallySendSurveyController - caseId - ' + caseId);
			system.debug('TRACE: ManuallySendSurveyController - caseType - ' + caseType);

			Post_Call_Survey_Frequency__c theFrequency = Post_Call_Survey_Frequency__c.getInstance(caseType);
			if(theFrequency != null) {
				Integer theSurveyFrequency = Integer.valueOf(theFrequency.Survey_Frequency__c);

				// Determining case contact's last survey send date.
				Date contactLastSurveySendDate = null;
				for(Case theCase : [SELECT Contact.Last_Survey_Send_Date__c FROM Case WHERE Id = :caseId limit 1]) {
					contactLastSurveySendDate = theCase.Contact.Last_Survey_Send_Date__c;
				}

				Date currentDate = Date.today();
				if(contactLastSurveySendDate == null || (currentDate >= contactLastSurveySendDate.addDays(theSurveyFrequency))) {
					update new Case(
						Id = caseId,
						Is_Manual_Survey_Send__c = true
					);
				}
				else {
					return 'Error: Survey cannot be sent before date - ' + String.valueOf(contactLastSurveySendDate.addDays(theSurveyFrequency));
				}
			}
			else {
				return 'Error: Unable to determine survey frequency for requested case type. Please contact system administrator.';
			}

			return 'Success: Survey sent successfully.';
		}
		catch(Exception e) {
			system.debug('TRACE: ManuallySendSurveyController - Exception Occurred - ' + e.getMessage());
			system.debug('TRACE: ManuallySendSurveyController - Exception Occurred - ' + e.getStackTraceString());

			return 'Error: An internal error occurred while processing your request. Please contact system administrator.';
		}
	}
}