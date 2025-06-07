// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAssessmentAdapter extends TypeAdapter<UserAssessment> {
  @override
  final int typeId = 5;

  @override
  UserAssessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAssessment(
      id: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      scores: (fields[2] as Map).cast<String, double>(),
      result: fields[3] as AssessmentResult,
      userId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserAssessment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.scores)
      ..writeByte(3)
      ..write(obj.result)
      ..writeByte(4)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAssessmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssessmentResultAdapter extends TypeAdapter<AssessmentResult> {
  @override
  final int typeId = 6;

  @override
  AssessmentResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AssessmentResult.screenTimeImbalance;
      case 1:
        return AssessmentResult.attentionDivided;
      case 2:
        return AssessmentResult.digitalStress;
      case 3:
        return AssessmentResult.productivityDisrupted;
      case 4:
        return AssessmentResult.balanced;
      default:
        return AssessmentResult.screenTimeImbalance;
    }
  }

  @override
  void write(BinaryWriter writer, AssessmentResult obj) {
    switch (obj) {
      case AssessmentResult.screenTimeImbalance:
        writer.writeByte(0);
        break;
      case AssessmentResult.attentionDivided:
        writer.writeByte(1);
        break;
      case AssessmentResult.digitalStress:
        writer.writeByte(2);
        break;
      case AssessmentResult.productivityDisrupted:
        writer.writeByte(3);
        break;
      case AssessmentResult.balanced:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
