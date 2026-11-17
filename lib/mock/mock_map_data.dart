import '../models/marker_data.dart';

abstract final class MockMapData {
  static const markers = <MarkerData>[
    MarkerData(
      id: 'a5',
      label: 'A5',
      name: 'Khu nhà A5',
      x: 0.24,
      y: 0.48,
      category: 'Khu khám bệnh',
      rooms: ['Phòng khám Da liễu', 'Khoa Nội tổng hợp', 'Quầy tiếp đón'],
    ),
    MarkerData(
      id: 'a7',
      label: 'A7',
      name: 'Khu nhà A7',
      x: 0.58,
      y: 0.51,
      category: 'Khu khám bệnh',
      rooms: ['Khoa Tim mạch', 'Phòng siêu âm', 'Quầy hướng dẫn'],
    ),
    MarkerData(
      id: 'a3',
      label: 'A3',
      name: 'Khu nhà A3',
      x: 0.46,
      y: 0.76,
      category: 'Khu khám bệnh',
      rooms: ['Khoa khám bệnh', 'Phòng lấy mẫu'],
    ),
    MarkerData(
      id: 'cluster-2',
      label: '2',
      name: 'Cụm 2 điểm dịch vụ',
      x: 0.22,
      y: 0.72,
      category: 'Điểm dịch vụ',
      isCluster: true,
      rooms: ['Cổng chính', 'Quầy thông tin'],
    ),
  ];
}
