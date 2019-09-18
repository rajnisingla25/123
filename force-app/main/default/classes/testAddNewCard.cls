@IsTest (SeeAllData=true)
public with sharing class testAddNewCard {

	static TestMethod void AddNewCardTest() {
		Test.startTest();
 
		// Instantiate Your Test Controller       
		AddNewCard anc = new AddNewCard();
		anc.getExtraParameters();
 		anc.successActions();
 		anc.getPageRef();
 		anc.getBackURL();
 		anc.getNextURL();
 		anc.navigateBack();
		// Call all the methods in your Class
		
		Test.stopTest();
	}
}