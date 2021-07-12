import common;

struct KDTree(size_t Dim) {
    alias PT = Point!Dim;
    class Node(size_t splitDim)
    {
        enum currLevel = splitDim;
        enum nextLevel = (splitDim + 1) % Dim;
        Node!nextLevel left, right;
        PT splitPT;
        this(PT[] points) {
            points.medianByDimension!currLevel;
            int median = cast(int) points.length / 2;
            splitPT = points[median];
            auto rightHalf = points[median + 1 .. $];
            auto leftHalf = points[0 .. median];
            if (leftHalf.length > 0) {
                left = new Node!nextLevel(leftHalf);
            }
            if (rightHalf.length > 0) {
                right = new Node!nextLevel(rightHalf);
            }
        }
    }
    private Node!0 root;
        this(PT[] points) {
        root = new Node!0(points);
    }
    PT[] rangeQuery(PT p, float r) {
        PT[] ret;
        void searchTree(size_t splitDim)(Node!splitDim n) {
            if (distance(p, n.splitPT) < r) {
                ret ~= n.splitPT;
            }
            if (p[splitDim] - r <= n.splitPT[splitDim] && n.left !is null) {
                searchTree(n.left);
            }
            if (p[splitDim] + r >= n.splitPT[splitDim] && n.right !is null) {
                searchTree(n.right);
            }
        }
        searchTree(root);
        return ret;
    }
    PT[] knnQuery(PT p, int k) {
        auto queue = makePriorityQueue(p);
        void searchTree(size_t splitDim, size_t Dim)(Node!splitDim n, AABB!Dim bucket) {
            if (queue.length < k) {
                queue.insert(n.splitPT);
            } else if (distance(p, queue.front) > distance(p, n.splitPT)) {
                queue.popFront;
                queue.insert(n.splitPT);
            }
            AABB!Dim leftBucket;
            leftBucket.min = bucket.min.dup;
            leftBucket.max = bucket.max.dup;
            leftBucket.max[splitDim] = n.splitPT[splitDim];
             if (n.left !is null && (queue.length < k || distance(closest(leftBucket, p), p) < distance(p, queue.front))) {
                searchTree(n.left, leftBucket);
            }
            AABB!Dim rightBucket;
            rightBucket.min = bucket.min.dup;
            rightBucket.max = bucket.max.dup;
            rightBucket.min[splitDim] = n.splitPT[splitDim];
            if (n.right !is null && (queue.length < k || distance(closest(rightBucket, p), p) < distance(p, queue.front))) {
                searchTree(n.right, rightBucket);
            }
        }
        AABB!Dim infinityBucket = AABB!Dim();
        infinityBucket.min[] = -float.infinity;
        infinityBucket.max[] = float.infinity;
        searchTree(root, infinityBucket);
        return queue.release;
    }
}

unittest{
    auto pts = [Point!2([.5, .5]), Point!2([1,1]),
                    Point!2([0.75, 0.4]), Point!2([0.4, 0.74])];
    auto kd_tree = KDTree!2(pts);
    writeln("kdtree rq:  ");
    foreach(p; kd_tree.rangeQuery(Point!2([1,1]), .7)){
        writeln(p);
    }
    writeln("kdtree kq:  ");
    foreach(p; kd_tree.knnQuery(Point!2([1,1]), 3)){
        writeln(p);
    }
}