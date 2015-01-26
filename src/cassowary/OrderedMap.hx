package cassowary;

import Map;


class OrderedMapIterator<K,V> {

    var map : OrderedMap<K,V>;
    var index : Int = 0;

    public function new(omap:OrderedMap<K,V>)
        map = omap;
    public function hasNext() : Bool
        return index < map._keys.length;
    public function next() : V
        return map.get( map._keys[index++] );

} //OrderedMapIterator

class OrderedMap<K, V> implements IMap<K, V> {

    var map:Map<K, V>;
    @:allow(cassowary.OrderedMapIterator)
    var _keys:Array<K>;
    var idx = 0;

    public function new(_map) {
       _keys = [];
       map = _map;
    }

    public function set(key, value) {
        if(_keys.indexOf(key) == -1) _keys.push(key);
        map[key] = value;
    }

    public function toString() {
        var _ret = ''; var _cnt = 0; var _len = _keys.length;
        for(k in _keys) _ret += '$k => ${map.get(k)}${(_cnt++<_len-1?", ":"")}';
        return '{$_ret}';
    }

    public function iterator()          return new OrderedMapIterator<K,V>(this);
    public function remove(key)         return map.remove(key) && _keys.remove(key);
    public function exists(key)         return map.exists(key);
    public function get(key)            return map.get(key);
    public inline function keys()       return _keys.iterator();

} //OrderedMap
