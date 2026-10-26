// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_media_read_reply.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DescriptorReply _$DescriptorReplyFromJson(Map<String, dynamic> json) =>
    DescriptorReply(
      fd: (json['fd'] as num).toInt(),
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      sizeInBytes: (json['sizeInBytes'] as num?)?.toInt(),
      isSeekable: json['isSeekable'] as bool,
    );

ChannelReply _$ChannelReplyFromJson(Map<String, dynamic> json) => ChannelReply(
  sessionId: json['sessionId'] as String,
  sizeInBytes: (json['sizeInBytes'] as num?)?.toInt(),
  isSeekable: json['isSeekable'] as bool,
);
