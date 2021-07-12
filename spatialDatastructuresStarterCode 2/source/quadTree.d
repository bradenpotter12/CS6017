import common;

struct QuadTree {
    alias PT = Point!2;
    
    class Node {
        bool isLeaf;
        PT[] points;
        Node nw, ne, sw, se;
        AABB!2 aabb;
        this(PT[] points, AABB!2 aabb) {
            if (points.length <= 64) {
                isLeaf = true;
                this.points = points.dup;
                this.aabb = aabb;
            } else {
                isLeaf = false;
                PT midpoint = (aabb.max + aabb.min) / 2;
                auto rightHalf = points.partitionByDimension!0(midpoint[0]);
                auto leftHalf = points[0 .. $ - rightHalf.length];
                auto upperRight = rightHalf.partitionByDimension!1(midpoint[1]);
                auto lowerRight = rightHalf[0 .. $ - upperRight.length];
                auto upperLeft = leftHalf.partitionByDimension!1(midpoint[1]);
                auto lowerLeft = leftHalf[0 .. $ - upperLeft.length];
                nw = new Node(upperLeft, boundingBox(upperLeft));
                ne = new Node(upperRight, boundingBox(upperRight));
                sw = new Node(lowerLeft, boundingBox(lowerLeft));
                se = new Node(lowerRight, boundingBox(lowerRight));    
            }
        }
    }

    private Node root;
    this(PT[] points) {
        root = new Node(points, boundingBox(points)); 
    }

    PT[] rangeQuery(Point!2 p, float r) {
        PT[] ret; //empty array
        void searchTree(Node node) {
            if (node.isLeaf == true) { 
                foreach(const ref q; node.points){ //foreach loop
                    if(distance(p, q) < r){
                        ret ~= q; //append to the array
                    }
                }
            } 
            else {
                auto children = [node.nw, node.ne, node.sw, node.se];
                foreach(child; children) {
                    auto x = closest(child.aabb, p);
                    if(distance(p, x) < r){
                        searchTree(child);
                    }
                }
            }
        }
        searchTree(root);
        return ret;
    }

    PT[] knnQuery(PT p, int k){
        PT[] ret;
        auto pq = makePriorityQueue(p);
        // pq.insert(root.points[0]);
        // writeln("FRONT ", pq.front);
        // writeln("HHHHHH ", pq);
        void searchTree(Node node){
            if (node.isLeaf == true) {
                foreach(const ref q; node.points){
                    if (pq.length < k){
                        pq.insert(q);
                    }
                    else if (distance(p, q) < distance(p, pq.front)){
                        pq.popFront;
                        pq.insert(q);
                    }
                }
            } else {
                auto children = [node.nw, node.ne, node.sw, node.se];
                foreach(child; children) {
                    auto x = closest(child.aabb, p);
                    if ((node.points.length < k) || (distance(p, x) < distance(p, pq.front))){
                        searchTree(child);
                    }
                }
            }
        }
        searchTree(root);
        foreach(const ref point; pq){ 
            ret ~= point;
        }
        return ret;
    }
}
            

unittest {
    auto points = [Point!2([.5, .5]), Point!2([1, 1]), Point!2([0.75, 0.4]), Point!2([0.4, 0.74])];
    auto qt = QuadTree(points);
    writeln("quadtree rq");
    foreach(p; qt.rangeQuery(Point!2([1,1]), .7)) {
        writeln(p);
    }
    writeln("quadtree knn");
    foreach(p; qt.knnQuery(Point!2([1,1]), 3)) {
        writeln(p);
    }
}

/*

        QT(points)
            root = new Node(points, AABB(points))


        Node(points, AABB)
            if points.length is small
                make this a leaf node
            else
                find midpoints  AABB max + min / 2
                partition the array [Ne, Nw, Se, Sw]
                for each child
                    Node(subset of points, sliced AABB)
    

        void Node::rq(P, r)
            if leaf
                for all points in the bucket
                    if distance (p, x) < r
                        add x to list
            else
                for each child
                    x = clamp(p, AABB min, AABB max) // closest point in bucket to p
                    if distance(p, x) <= r
                        Node::rq(P, r)

        void Node::Knn(P, K)
            if leaf
                for each point in bucket
                    if list.length < K
                        add point
                    else if distance(p, x) < distance(p, worst in list)
                        replace worst with x
            else
                for each child
                    x = clamp(p, AABB min, AABB max)
                    if list.length < K or distance(p, x) < worst point in list
                        Node::Knn(P, K)

*/