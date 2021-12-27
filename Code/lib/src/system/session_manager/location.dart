import 'dart:math';

class Location{
  String id ="";
  String name="";
  double xPos= 0;
  double yPos= 0;
  static Random rng = Random();
  Location(this.id, this.name, this.xPos, this.yPos);

  ///Test dummy functions
  ///
  Location.dummy(){
    name = getRandom().name;
  }

  ///Test dummy functions
  ///
  static List<Location> locations= [
    Location( '0', 'Tennis Court 1, Lakeshore', 43.076975, -89.415536),
    Location( '1', 'Tennis Court 2, Lakeshore', 43.076975, -89.415367),
    Location( '2', 'Tennis Court 3, Lakeshore', 43.076975, -89.415200),
    Location( '3', 'Tennis Court 4, Lakeshore', 43.076975, -89.415018),
    Location( '4', 'Tennis Court 5, Lakeshore', 43.076975, -89.414850),
    Location( '5', 'Tennis Court 6, Lakeshore', 43.076975, -89.414682),
    Location( '6', 'Tennis Court 7, Lakeshore', 43.076752, -89.414396),
    Location( '7', 'Tennis Court 8, Lakeshore', 43.076747, -89.414216),
    Location( '8', 'Tennis Court 9, Lakeshore', 43.076744, -89.414036),
    Location( '9', 'Basketball Court 1, Lakeshore', 43.077165, -89.414388),
    Location( '10', 'Basketball Court 2, Lakeshore', 43.077165, -89.414028),
    Location( '11', 'Basketball Court 3, Lakeshore', 43.076982, -89.414388),
    Location( '12', 'Basketball Court 4, Lakeshore', 43.076982, -89.414028),
    Location( '13', 'Volleyball Court 1, Lakeshore', 43.076690, -89.415390),
    Location( '14', 'Volleyball Court 2, Lakeshore', 43.076690, -89.415234),
    Location( '15', 'Volleyball Court 3, Lakeshore', 43.076690, -89.415034),
    Location( '16', 'Volleyball Court 4, Lakeshore', 43.076689, -89.414870),
    Location( '17', 'Soccer Field 1, Near East Fields', 43.077000, -89.417250)
  ];

  ///Test dummy functions
  ///
  @override
  String toString(){
    return name;
  }

  ///Test dummy functions
  ///
  static Location getRandom(){
    return locations[rng.nextInt(locations.length)];
  }
  static Location? getLocationByID(String id){
    for(var l in locations){
      if(l.id == id){
        return l;
      }
    }
    return null;
  }


}