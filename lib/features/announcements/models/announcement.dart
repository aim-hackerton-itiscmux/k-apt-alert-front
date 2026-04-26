class Announcement {
  const Announcement({
    required this.id,
    required this.name,
    required this.region,
    required this.district,
    required this.address,
    required this.period,
    required this.rceptEnd,
    required this.totalUnits,
    required this.houseType,
    required this.houseCategory,
    required this.constructor,
    required this.url,
    required this.size,
    required this.speculativeZone,
    required this.priceControlled,
    required this.scheduleSource,
    this.rceptBgn,
    this.noticeDate,
    this.winnerDate,
    this.contractStart,
    this.contractEnd,
    this.dDay,
    this.dDayLabel,
  });

  final String id;
  final String name;
  final String region;
  final String district;
  final String address;
  final String period;
  final String rceptEnd;
  final String totalUnits;
  final String houseType;
  final String houseCategory;
  final String constructor;
  final String url;
  final String size;
  final String speculativeZone;
  final String priceControlled;
  final String scheduleSource;
  final String? rceptBgn;
  final String? noticeDate;
  final String? winnerDate;
  final String? contractStart;
  final String? contractEnd;
  final int? dDay;
  final String? dDayLabel;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    String s(String key) => (json[key] ?? '').toString();
    String? sn(String key) {
      final v = json[key];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return Announcement(
      id: s('id'),
      name: s('name'),
      region: s('region'),
      district: s('district'),
      address: s('address'),
      period: s('period'),
      rceptEnd: s('rcept_end'),
      totalUnits: s('total_units'),
      houseType: s('house_type'),
      houseCategory: s('house_category'),
      constructor: s('constructor'),
      url: s('url'),
      size: s('size'),
      speculativeZone: s('speculative_zone'),
      priceControlled: s('price_controlled'),
      scheduleSource: s('schedule_source'),
      rceptBgn: sn('rcept_bgn'),
      noticeDate: sn('notice_date'),
      winnerDate: sn('winner_date'),
      contractStart: sn('contract_start'),
      contractEnd: sn('contract_end'),
      dDay: asInt(json['d_day']),
      dDayLabel: sn('d_day_label'),
    );
  }
}
