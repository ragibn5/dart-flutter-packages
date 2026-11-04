import 'package:media_provider_android/src/models/file_location.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/media_type.dart';
import 'package:media_provider_android/src/models/volume_identity.dart';
import 'package:media_provider_android/src/models/volume_type.dart';

/// The primary volume, as the platform side reports it.
const primaryVolumeIdentity = VolumeIdentity(
  uuid: null,
  type: VolumeType.primary,
  volumePath: '/storage/emulated/0',
  capacityInBytes: 128000000000,
  isPrimary: true,
  isRemovable: false,
  isEmulated: true,
);

/// [primaryVolumeIdentity], encoded the way the platform side sends it.
const primaryVolumeIdentityJson = <String, dynamic>{
  'uuid': null,
  'type': 'PRIMARY',
  'volumePath': '/storage/emulated/0',
  'capacityInBytes': 128000000000,
  'isPrimary': true,
  'isRemovable': false,
  'isEmulated': true,
};

/// A photo backed by a file on the primary volume.
const photoItem = MediaItem(
  type: MediaType.photo,
  uri: 'content://media/external/images/media/1',
  id: '1',
  fileLocation: FileLocation(
    volumeIdentity: primaryVolumeIdentity,
    relativeParentPath: 'DCIM/Camera',
    fileNameWithExtension: 'IMG_0001.jpg',
    absoluteFilePath: '/storage/emulated/0/DCIM/Camera/IMG_0001.jpg',
  ),
  name: 'IMG_0001.jpg',
  mimeType: 'image/jpeg',
  sizeInBytes: 2048,
  dateAddedInMillis: 1700000000000,
  dateModifiedInMillis: 1700000001000,
  dateTakenInMillis: 1700000002000,
  ownerPackageName: 'com.android.camera',
  isPending: false,
  isTrashed: false,
  isFavorite: true,
  isDownloaded: false,
);

/// [photoItem], encoded the way the platform side sends it.
const photoItemJson = <String, dynamic>{
  'type': 'PHOTO',
  'uri': 'content://media/external/images/media/1',
  'id': '1',
  'fileLocation': <String, dynamic>{
    'volumeIdentity': primaryVolumeIdentityJson,
    'relativeParentPath': 'DCIM/Camera',
    'fileNameWithExtension': 'IMG_0001.jpg',
    'absoluteFilePath': '/storage/emulated/0/DCIM/Camera/IMG_0001.jpg',
  },
  'name': 'IMG_0001.jpg',
  'mimeType': 'image/jpeg',
  'sizeInBytes': 2048,
  'dateAddedInMillis': 1700000000000,
  'dateModifiedInMillis': 1700000001000,
  'dateTakenInMillis': 1700000002000,
  'ownerPackageName': 'com.android.camera',
  'isPending': false,
  'isTrashed': false,
  'isFavorite': true,
  'isDownloaded': false,
};

/// A video with no backing file, and every optional field absent.
const videoItemWithoutFile = MediaItem(
  type: MediaType.video,
  uri: 'content://media/external/video/media/2',
  id: '2',
  fileLocation: null,
  name: null,
  mimeType: null,
  sizeInBytes: null,
  dateAddedInMillis: null,
  dateModifiedInMillis: null,
  dateTakenInMillis: null,
  ownerPackageName: null,
  isPending: null,
  isTrashed: null,
  isFavorite: null,
  isDownloaded: null,
);
