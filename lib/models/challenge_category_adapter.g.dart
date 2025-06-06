// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_category_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeCategoryAdapter extends TypeAdapter<ChallengeCategory> {
  @override
  final int typeId = 2;

  @override
  ChallengeCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeCategory.screenTime;
      case 1:
        return ChallengeCategory.focus;
      case 2:
        return ChallengeCategory.notifications;
      default:
        return ChallengeCategory.screenTime;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeCategory obj) {
    switch (obj) {
      case ChallengeCategory.screenTime:
        writer.writeByte(0);
        break;
      case ChallengeCategory.focus:
        writer.writeByte(1);
        break;
      case ChallengeCategory.notifications:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
