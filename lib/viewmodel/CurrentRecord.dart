class CurrentRecord {
  String content;
  int bookId;
  String bookName;
  String bookImage;
  int id;

  CurrentRecord({
    this.content = '',
    this.bookId = 0,
    this.id = 0,
    this.bookName = '',
    this.bookImage = '',
  });
}

// class TipRecord extends Table
//     with AutoIncrementingPrimaryKey, CreateDateTimeColumn, RemarksColumn {
//   TextColumn get content => text()();
//   IntColumn get bookId => integer()();
// }
