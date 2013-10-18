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
   * This method is necessary for the Visualforce page, in order to
   * reference non-standard fields.
   */
  public List<Contact> getChildren()
  {
    return castList(childList);
  }

  public override void addToList()
  {
    Contact child = new Contact();
    // Can either use mysObject or acct here
    child.AccountId = mysObject.Id;
    
    childList.add(child);
  }

  public override List<sObject> castList(List<sObject> myList)
  {
    return (List<Contact>)myList;
  }
}