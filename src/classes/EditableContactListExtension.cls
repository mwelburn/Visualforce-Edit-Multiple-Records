/*
 * EditableContactListExtension.cls
 *
 * Copyright (c)2013, Michael Welburn.
 * License: MIT
 *
 * Usage:
 *   This is the implementation class where Object specific references
 *   need to be defined. Please see EditableList.cls for more information
 *   on what each method is responsible for.
 *
 *   Required methods:
 *     - EditableContactListExtension(ApexPages.StandardController)
 *     - getChildren()
 *     - initChildRecord()
 *
 */
public with sharing class EditableContactListExtension extends EditableList
{
  // Read the explanation in EditableContactListExtension(ApexPages.StandardController)
  // to see when to uncomment the following line.

  // public Account myAccount {get; private set;}

  public EditableContactListExtension(ApexPages.StandardController stdController) 
  {
    super(stdController);

    // If necessary, explicitly query for additional metadata on parent record
    // if you are looking to display things that don't come back with the
    // StandardController. In that case, you will need to replace the "Account.X"
    // references in the Visualforce Page with references to an Account variable
    // that you will need to declare in this class (myAccount.X). I have commented out
    // an example.

    // this.myAccount = [SELECT Id,
    //                            Name,
    //                            Custom_Relationship__r.Name
    //                        FROM Account
    //                        WHERE Id =: stdController.getRecord().Id];
    
    this.childList = [SELECT Id,
                          FirstName,
                          LastName,
                          Email
                      FROM Contact
                      WHERE AccountId =: mysObject.Id];
  }

  /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<Contact> getChildren()
  {
    return (List<Contact>)childList;
  }

  public override sObject initChildRecord()
  {
    Contact child = new Contact();
    // Can either use mysObject or acct here
    child.AccountId = mysObject.Id;
    
    return child;
  }
}