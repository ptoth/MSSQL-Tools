CREATE Table tblAuthors
(
   Id int identity primary key,
   Author_name nvarchar(50),
   country nvarchar(50)
)
CREATE Table tblBooks
(
   Id int identity primary key,
   Auhthor_id int foreign key references tblAuthors(Id),
   Price int,
   Edition int
)

Declare @Id int
Set @Id = 1

While @Id <= 12000
Begin
   Insert Into tblAuthors
   values
      ('Author - ' + CAST(@Id as nvarchar(10)),
         'Country - ' + CAST(@Id as nvarchar(10)) + ' name')
   Print @Id
   Set @Id = @Id + 1
End

Declare @RandomAuthorId int
Declare @RandomPrice int
Declare @RandomEdition int

Declare @LowerLimitForAuthorId int
Declare @UpperLimitForAuthorId int

Set @LowerLimitForAuthorId = 1
Set @UpperLimitForAuthorId = 12000


Declare @LowerLimitForPrice int
Declare @UpperLimitForPrice int

Set @LowerLimitForPrice = 50
Set @UpperLimitForPrice = 100

Declare @LowerLimitForEdition int
Declare @UpperLimitForEdition int

Set @LowerLimitForEdition = 1
Set @UpperLimitForEdition = 10


Declare @count int
Set @count = 1

While @count <= 20000
Begin

   Select @RandomAuthorId = Round(((@UpperLimitForAuthorId - @LowerLimitForAuthorId) * Rand()) + @LowerLimitForAuthorId, 0)
   Select @RandomPrice = Round(((@UpperLimitForPrice - @LowerLimitForPrice) * Rand()) + @LowerLimitForPrice, 0)
   Select @RandomEdition = Round(((@UpperLimitForEdition - @LowerLimitForEdition) * Rand()) + @LowerLimitForEdition, 0)


   Insert Into tblBooks
   values
      (@RandomAuthorId, @RandomPrice, @RandomEdition)
   Print @count
   Set @count = @count + 1
End