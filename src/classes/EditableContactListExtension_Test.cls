@isTest
private class EditableContactListExtension_Test 
{
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

  @isTest static void test_EditableContactListExtension()
  {
    setupData();

    Test.startTest();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    EditableContactListExtension ext = new EditableContactListExtension(std);

    Test.stopTest();

    System.assertEquals(0, ext.ZERO);
    System.assertEquals(0, ext.removeChildList.size());
    System.assertEquals(2, ext.childList.size());
  }

  @isTest static void test_getChildren()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    EditableContactListExtension ext = new EditableContactListExtension(std);
    
    Test.startTest();

    System.assert(ext.getChildren() instanceof List<Contact>);

    Test.stopTest();    
  }

  @isTest static void test_initChildRecord()
  {
    setupData();

    ApexPages.StandardController std = new ApexPages.StandardController(acct);
    EditableContactListExtension ext = new EditableContactListExtension(std);

    Test.startTest();

    System.assert(ext.initChildRecord() instanceof Contact);
    Contact myContact = (Contact)ext.initChildRecord();
    
    Test.stopTest();

    System.assertEquals(acct.Id, myContact.AccountId);
  }
}