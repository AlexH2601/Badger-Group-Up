import 'package:postgres/postgres.dart';
import 'package:flutter/material.dart'; // Debug statements only

// Postgres package: https://pub.dev/documentation/postgres/latest/
class Database {
  static DatabaseMockito instance = DatabaseMockito();

  static PostgreSQLConnection _initDBConnection() {
    return PostgreSQLConnection("ec2-3-226-165-74.compute-1.amazonaws.com", 5432, "d93i21igm2u95t", username: "xxvfbiolchuriu", password: "8d921af99adec842d518e2918bf382847050c56d75af367971962286035d5042", useSSL: true);
  }

  /// Intermediate Flutter - Postgres select method to send SELECT queries |
  /// [String relation]: name of the target Postgres relation |
  /// [bool all]: specify if this is a "SELECT *" query or an output specific query (if all is set to false, outputAttributes should be defined) |
  /// [List<String> outputAttributes]: a list of the relation attributes to include in the output |
  /// [Map<String, String> conditionals]: a map of (attribute, value) pairs to be included in the WHERE clause
  static Future<List<List<dynamic>>> select(String relation, {bool all = true, List<String> outputAttributes = const [], Map<String, String> conditionals = const {}}) async {
    var connection = _initDBConnection();
    await connection.open();

    // Create Postgres query
    String query = "SELECT ";

    // Either select all attributes or only some
    if (all) {
      query += "*";
    }
    else {
      for (String attribute in outputAttributes) {
        query += (attribute + ', ');
      }
      query = query.substring(0, query.length - 2);
    }

    // Add target relation
    query += " FROM \"$relation\"";

    // Check for conditional select query and exeucte
    List<List<dynamic>> results = [];
    if (conditionals.isEmpty) {
      try {
        results = await connection.query(query);
      }
      catch (e) {
        connection.close();
        debugPrint(e.toString());
        return [];
      }
    }
    else {
      query += " WHERE ";

      // Add conditionals to query
      conditionals.forEach((attribute, value) => (query += '$attribute = @$attribute AND '));

      query = query.substring(0, query.length - 4);

      try {
        results = await connection.query(query, substitutionValues: conditionals);
      }
      catch (e) {
        connection.close();
        debugPrint(e.toString());
        return [];
      }
    }

    connection.close();
    return results;
  }

  /// Intermediate Flutter - Postgres update method to send UPDATE queries
  /// [String relation]: name of the target Postgres relation |
  /// [Map<string, String> newValues]: a map of (attribute, value) pairs to set new values
  /// [Map<String, String> conditionals]: a map of (attribute, value) pairs to be included in the WHERE clause
  static Future<bool> update(String relation, Map<String, String> newValues, Map<String, String> conditionals) async {
    var connection = _initDBConnection();
    await connection.open();

    // Create Postgres query
    String query = "UPDATE \"$relation\" SET ";

    // Add SET values to query
    newValues.forEach((attribute, value) => (query += '$attribute = @$attribute, '));

    query = query.substring(0, query.length - 2);

    if (conditionals.isNotEmpty) {
      query += " WHERE ";
      conditionals.forEach((attribute, value) => (query += '$attribute = @$attribute AND '));
    }

    query = query.substring(0, query.length - 5);

    bool success = true;

    // Send query to database and check for exception (success vs failure)
    try {
      await connection.query(query, substitutionValues: {...newValues, ...conditionals});
    }
    catch (e) {
      success = false;
    }

    connection.close();
    return success;
  }

  /// Intermediate Flutter - Postgres insert method to send INSERT INTO queries
  /// [String relation]: name of the target Postgres relation |
  /// [Map<String, String> attributes]: a map of (attribute, value) pairs to be included in the relation (must be in order!)
  static Future<bool> insert(String relation, Map<String, String> attributes) async {
    var connection = _initDBConnection();
    await connection.open();

    // Create Postgres query
    String query = "INSERT INTO \"$relation\" VALUES(";

    // Format query into "INSERT INTO $relation VALUES(@attribute1, @attribute2, ...)"
    attributes.forEach((attribute, value) => (query += '@$attribute, '));

    query = query.substring(0, query.length - 2);
    query += ")";

    bool success = true;

    // Send query to database and check for exception (success vs failure)
    try {
      await connection.query(query, substitutionValues: attributes);
    }
    catch (e) {
      debugPrint(e.toString());
      success = false;
    }

    connection.close();
    return success;
  }

  /// Intermediate Flutter - Postgres delete method to send DELETE queries
  /// [String relation]: name of the target Postgres relation |
  /// [Map<String, String> conditionals]: map of (attribute, value) pairs to be included in the WHERE clause
  static Future<bool> delete(String relation, Map<String, String> conditionals) async {
    var connection = _initDBConnection();
    await connection.open();

    String query = "DELETE FROM \"$relation\"";

    if (conditionals.isNotEmpty) {
      query += ' WHERE ';
      conditionals.forEach((attribute, value) => (query += '$attribute = @$attribute AND '));
      query = query.substring(0, query.length - 5);
    }

    debugPrint(query);

    bool success = true;

    try {
      await connection.query(query, substitutionValues: conditionals);
    }
    catch (e) {
      debugPrint(e.toString());
      success = false;
    }

    connection.close();
    return success;
  }
}

// Mockito OOP-based testing class
class DatabaseMockito {
  Future<List<List<dynamic>>> select(String relation, {bool all = true, List<String> outputAttributes = const [], Map<String, String> conditionals = const {}}) async
    => Database.select(relation, all: all, outputAttributes: outputAttributes, conditionals: conditionals);

  Future<bool> update(String relation, Map<String, String> newValues, Map<String, String> conditionals) async
    => Database.update(relation, newValues, conditionals);

  Future<bool> insert(String relation, Map<String, String> attributes) async
    => Database.insert(relation, attributes);

  Future<bool> delete(String relation, Map<String, String> conditionals) async
    => Database.delete(relation, conditionals);
}