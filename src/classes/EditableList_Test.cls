/*
 * EditableList_Test.cls
 *
 * Copyright (c)2013, Michael Welburn.
 * License: MIT
 *
 * Usage:
 *   Test class for EditableList.cls
 *
 */
@isTest
private class EditableList_Test 
{	
  /*
   * Mock implementation of abstract class used for testing
   */
	private class MockEditableList extends EditableList
  {
    public MockEditableList(ApexPages.StandardController stdController)
    {
      super(stdController);
    } 
  }

  private static Account acct;
  private static Contact myContact1;
  private static Contact myContact2;

  private static void setupData()
  {
    acct = new Account();
    acct.Name = 'Test Account 1';
    insert acct;

    myContact1 = new Contact();
    myContact1.LastName = 'Smith';
    myContact1.AccountId = acct.Id;
    insert myContact1;

    myContact2 = new Contact();
    myContact2.LastName = 'Smith';
    myContact2.AccountId = acct.Id;
    insert myContact2;
  }
	
	@isTest static void test_EditableList() 
  {
		setupData();

    Test.startTest();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    MockEditableList mock = new MockEditableList(std);

    Test.stopTest();

    System.assertEquals(0, mock.ZERO);
    System.assertEquals(0, mock.childList.size());
    System.assertEquals(0, mock.removeChildList.size());
	}
	
  @isTest static void test_getHasChildren()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    MockEditableList mock = new MockEditableList(std);

    Test.startTest();

    System.assertEquals(false, mock.getHasChildren());

    mock.childList.add(new Contact());

    System.assertEquals(true, mock.getHasChildren());

    Test.stopTest();
  }

  @isTest static void test_initChildRecord()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    MockEditableList mock = new MockEditableList(std);

    Test.startTest();

    System.assert(mock.initChildRecord() instanceof Contact);
    
    Test.stopTest();
  }

  @isTest static void test_addToList()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    MockEditableList mock = new MockEditableList(std);

    System.assertEquals(0, mock.childList.size());

    Test.startTest();

    mock.addToList();

    Test.stopTest();

    System.assertEquals(1, mock.childList.size());
  }

  @isTest static void test_removeFromList()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    MockEditableList mock = new MockEditableList(std);

    mock.childList.add(myContact1);
    mock.childList.add(myContact2);

    Test.startTest();

    mock.removeIndex = '1';
    mock.removeFromList();

    Test.stopTest();

    System.assertEquals(1, mock.childList.size());
    System.assertEquals(myContact2.Id, mock.childList[0].Id);
    System.assertEquals(1, mock.removeChildList.size());
    System.assertEquals(myContact1.Id, mock.removeChildList[0].Id);
  }

  @isTest static void test_getSuccessURL_param()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    MockEditableList mock = new MockEditableList(std);

    String retURL = '/test';
    PageReference pr = new PageReference('/');
    pr.getParameters().put('retURL', retURL);

    Test.setCurrentPageReference(pr);
    Test.startTest();

    System.assertEquals(retURL, mock.getSuccessURL().getUrl());

    Test.stopTest();
  }

  @isTest static void test_getSuccessURL_noParam()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    MockEditableList mock = new MockEditableList(std);

    PageReference pr = new PageReference('/');

    Test.setCurrentPageReference(pr);
    Test.startTest();

    System.assertEquals(std.view().getUrl(), mock.getSuccessURL().getUrl());

    Test.stopTest();
  }

  @isTest static void test_save_failure()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    MockEditableList mock = new MockEditableList(std);

    mock.childList.add(myContact1);
    mock.removeChildList.add(myContact2);

    // Purposely leave out required LastName
    Contact newContact = new Contact();
    newContact.AccountId = acct.Id;

    mock.childList.add(newContact);

    Test.startTest();

    System.assertEquals(null, mock.save());

    Test.stopTest();

    System.assertEquals(1, ApexPages.getMessages().size());
    System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity());
    
  }

  @isTest static void test_save_success()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    MockEditableList mock = new MockEditableList(std);

    mock.childList.add(myContact1);
    mock.removeChildList.add(myContact2);

    Contact newContact = new Contact();
    newContact.LastName = 'Test';
    newContact.AccountId = acct.Id;

    mock.childList.add(newContact);

    Test.startTest();

    System.assertEquals(mock.getSuccessURL().getUrl(), mock.save().getUrl());

    Test.stopTest();

    List<sObject> results = [SELECT Id FROM Contact WHERE AccountId =: acct.Id ORDER BY CreatedDate];
    System.assertEquals(2, results.size());
    System.assertEquals(myContact1.Id, results[0].Id);
    System.assertNotEquals(myContact2.Id, results[1].Id);
  }
}