import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

class VndbInstance {
  final String eot = String.fromCharCode(0x04);
  Socket? socket;
  String? serverResponse;
  Future<void> connect() async {
    socket = await Socket.connect('api.vndb.org', 19534);
    if (socket != null) {
      print(
          'Connected to: ${socket!.remoteAddress.address}:${socket!.remotePort}');
    } else {
      print('Connection failed');
    }

    StreamSubscription<Uint8List>? streamSubscription;
    streamSubscription = socket?.listen((Uint8List data) {
      serverResponse = String.fromCharCodes(data);
      print('Server: $serverResponse');
    });
  }

  Future<void> closeConnection() async {
    await socket?.close();
    print('Disconnected...!');
  }

  Future<void> login({
    required int protocol,
    required String client,
    required String clientversion,
    String? username,
    String? password,
  }) async {
    final query = LoginQuery(
        protocol: protocol, client: client, clientVersion: clientversion);
    socket?.write('login ${jsonEncode(query.toJson())}$eot');
  }

  Future<void> getVNs({
    List<int>? id,
    String? title,
    String? original,
    String? firstchar,
    String? released,
    List<String>? platforms,
    List<String>? languages,
    String? originalLanguage,
    String? search,
    List<int>? tags,
  }) async {
    final requestString = 'get vn basic (id = $id)$eot';
    socket?.write(requestString);
  }
}

void main(List<String> arguments) async {
  VndbInstance instance = VndbInstance();
  await instance.connect();
  print('Connected!');

  await instance.login(protocol: 1, client: 'MIKAELCG', clientversion: '1.0');
  await instance.getVNs(id: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
  await instance.closeConnection();
}

class DBStats {
  final int users;
  final int threads;
  final int tags;
  final int releases;
  final int producers;
  final int chars;
  final int posts;
  final int vn;
  final int traits;

  @override
  String toString() {
    return '$users, $threads, $tags, $releases, $producers, $chars, $posts, $vn, $traits';
  }

  DBStats(
      {required this.users,
      required this.threads,
      required this.tags,
      required this.releases,
      required this.producers,
      required this.chars,
      required this.posts,
      required this.vn,
      required this.traits});

  factory DBStats.fromJson(Map<String, dynamic> json) {
    return DBStats(
      users: json['users'] as int,
      threads: json['threads'] as int,
      tags: json['tags'] as int,
      releases: json['releases'] as int,
      producers: json['producers'] as int,
      chars: json['chars'] as int,
      posts: json['posts'] as int,
      vn: json['vn'] as int,
      traits: json['traits'] as int,
    );
  }
}

class LoginQuery {
  // login {"protocol":1,"client":"test","clientver":0.1,"username":"ayo","password":"hi-mi-tsu!"}
  final int protocol;
  final String client;
  final String clientVersion;
  String? username;
  String? password;

  LoginQuery(
      {required this.protocol,
      required this.client,
      required this.clientVersion});

  Map<String, dynamic> toJson() => {
        'protocol': protocol,
        'client': client,
        'clientver': clientVersion,
      };
}

class GetVNQuery {}
