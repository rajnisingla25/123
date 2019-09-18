//
// (c) 2015 Appirio, Inc.
//
// Apex Class Name: CreateArticleFeedbackController_Test
// Description: Test Class for CreateArticleFeedbackController
//
// 26th March 2015    Ravindra Shekhawat    Original (Task # T-373305 )
@isTest
public with sharing class CreateArticleFeedbackController_Test {
    
     static testMethod void testArticleFeedbackController(){
     
      List<FAQ__kav> articleList = new List<FAQ__kav>();
      // Create FAQ_kav Articles
      for(Integer i=0;i<2;i++){
        articleList.add(TestDataFactory.createFAQArticle(true,'Test Article',i));
      }
      
      String articleId = articleList.get(0).Id;
          
      Test.startTest();
       
        FAQ__kav insertedTestFaq = [Select KnowledgeArticleId from FAQ__kav where Id = :articleId];
        // Publish
        KbManagement.PublishingService.publishArticle(insertedTestFaq.KnowledgeArticleId, true);
       
        Article_Feedback__c  feedback = new Article_Feedback__c();
        CreateArticleFeedbackController controller = new CreateArticleFeedbackController();
     
        ApexPages.currentPage().getParameters().put('id',insertedTestFaq.KnowledgeArticleId);
        feedback.Comments__c = 'Feeback : Test Feedback';
        feedback.Is_Helpful__c = true;
        controller.articleFeedback = feedback;
        controller.createArticleFeedback();
        
        List<Article_Feedback__c> feedbackList = [SELECT Article_Id__c,Comments__c FROM Article_Feedback__c WHERE Article_Id__c=:insertedTestFaq.KnowledgeArticleId];
        System.assert(feedbackList.size() ==1);
        delete feedback;
       
        controller.knowledgeArticle = null;
        //Test Article Feedback without Comments
        feedback = new Article_Feedback__c();
        feedback.Is_Helpful__c = true;
        controller.articleFeedback = feedback;
        controller.createArticleFeedback();
        
        // Assert that Article Feedback is Created
        feedbackList = [SELECT Article_Id__c,Comments__c FROM Article_Feedback__c WHERE Article_Id__c=:insertedTestFaq.KnowledgeArticleId];
        System.assert(feedbackList.size() ==0);
            //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        // Test for Non-Article Type Objects
        Account testAccount = TestDataFactory.createAccount('TestAccount', null,false);
        testAccount.Primary_Email__c = 'testAcc@move.com';
        insert testAccount;
        ApexPages.currentPage().getParameters().put('id',testAccount.Id);
        feedback = new Article_Feedback__c();
        feedback.Is_Helpful__c = true;
        feedback.Comments__c ='Test FEED';
        controller.articleFeedback = feedback;
        controller.createArticleFeedback();
       
        // Assert that Feedback in Not Created for Nor-Article Type Object  
        feedbackList = [SELECT Article_Id__c,Comments__c FROM Article_Feedback__c WHERE Article_Id__c=:insertedTestFaq.KnowledgeArticleId];
        System.assert(feedbackList.size() == 0);

        // Tes for Unpublished Articles
        insertedTestFaq = [Select KnowledgeArticleId,PublishStatus from FAQ__kav where Id = :articleList.get(1).Id];
        ApexPages.currentPage().getParameters().put('id',insertedTestFaq.KnowledgeArticleId);
        feedback = new Article_Feedback__c();
        feedback.Is_Helpful__c = true;
        controller.articleFeedback = feedback;
        controller.createArticleFeedback();
        System.assert(insertedTestFaq.PublishStatus == 'Draft');
        
        // Assert that feedback is Not Created for Unpublished Articless
        feedbackList = [SELECT Article_Id__c,Comments__c FROM Article_Feedback__c WHERE Article_Id__c=:insertedTestFaq.KnowledgeArticleId];
        System.assert(feedbackList.size() ==0);
       
      Test.stopTest(); 
        
     }

}