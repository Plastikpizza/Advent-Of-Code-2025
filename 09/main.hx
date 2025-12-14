import haxe.macro.Compiler.IncludePosition;
import haxe.ds.IntMap;
import sys.io.File;
import Lambda;
import haxe.Int64;

class Coord {
    public var x : Int;
    public var y : Int;
    public function new(x : Int, y : Int) {
        this.x = x;
        this.y = y;
    }
}

class Hline {
    public var x1 : Int;
    public var x2 : Int;
    public function new(x1 : Int, x2 : Int) {
        this.x1 = x1;
        this.x2 = x2;
    }
}

class Line {
    public var p1 : Coord;
    public var p2 : Coord;
    public function new(p1 : Coord, p2 : Coord) {
        this.p1 = p1;
        this.p2 = p2;
    }
}

function boxSize(p1 : Coord, p2 : Coord) : Int64 {
    var dx:Int64 = p1.x - p2.x;
    if (dx < 0) {
        dx *= -1;
    }
    var dy:Int64 = p1.y - p2.y;
    if (dy < 0) {
        dy *= -1;
    }
    return (dx+1) * (dy+1);
}

class Main {
    static public function main():Void {
        var args = Sys.args();
        var filename = args[0];
        var content = File.getContent(filename);
        var redTiles : Array<Coord> = new Array();
        var outline : Array<Line> = new Array();
        var last : Coord = null;
        for (line in content.split("\n")) {
            var coordPair = Lambda.map(line.split(","), x -> Std.parseInt(x));
            var coord = new Coord(coordPair[0], coordPair[1]);
            redTiles.push(coord);
            if (last != null) {
                outline.push(new Line(last, coord));
            }
            last = coord;
        }
        outline.push(new Line(last, redTiles[0]));
        var largest : Int64 = 0;
        for (i1 in 0...(redTiles.length-1)) {
            for (i2  in (i1+1)...redTiles.length) {
                var p1 = redTiles[i1];
                var p2 = redTiles[i2];
                var size = boxSize(p1, p2);
                if (size > largest) {
                    largest = size;
                }
            }
        }
        trace('Part 1: ${largest}');
        var edgeMap : IntMap<Hline> = new IntMap();
        for (edge in outline) {
            if (edge.p1.x == edge.p2.x) {
                // vertical
                var ym = edge.p1.y;
                if (edge.p2.y < ym) ym = edge.p2.y;
                var Y = edge.p1.y;
                if (edge.p2.y > Y) Y = edge.p2.y;
                var ok = true;
                for (y in ym...Y) {
                    if (edgeMap.exists(y)) {
                        var h = edgeMap.get(y);
                        if (h.x1 > edge.p1.x) {
                            h.x1 = edge.p1.x;
                        } else if (h.x2 < edge.p1.x) {
                            h.x2 = edge.p1.x;
                        }
                        edgeMap.set(y, h);
                    } else {
                        edgeMap.set(y, new Hline(edge.p1.x,edge.p1.x));
                    }
                }
            } else {
                // horizontal
                var y = edge.p1.y;
                var h = null;
                if (edgeMap.exists(y)) {
                    h = edgeMap.get(y);
                } else {
                    h = new Hline(edge.p1.x,edge.p1.x);
                }
                for (x in [edge.p1.x, edge.p2.x]) {
                    if(x < h.x1) {
                        h.x1 = x;
                    } else if (x > h.x2) {
                        h.x2 = x;
                    }
                }
                edgeMap.set(y, h);
            }
        }
        largest = 0;
        for (i1 in 0...(redTiles.length-1)) {
            for (i2  in (i1+1)...redTiles.length) {
                var p1 = redTiles[i1];
                var p2 = redTiles[i2];
                var ym = p1.y;
                if (p2.y < ym) ym = p2.y;
                var Y = p1.y;
                if (p2.y > Y) Y = p2.y;
                var ok = true;
                for (y in ym...Y) {
                    var h = edgeMap.get(y);
                    if (p1.x < h.x1 || p1.x > h.x2 || p2.x < h.x1 || p2.x > h.x2) {
                        ok = false;
                        break;
                    }
                }
                if(!ok) {
                    continue;
                } else {
                    var size = boxSize(p1, p2);
                    if (size > largest) {
                        largest = size;
                    }
                }
            }
        }
        trace('part 2: ${largest}');
    }
}
