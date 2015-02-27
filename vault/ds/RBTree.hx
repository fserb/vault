package vault.ds;

// ---------------------------------------------------------------------------
// Red-Black tree code (based on C version of "rbtree" by Franck Bui-Huu
// https://github.com/fbuihuu/libtree/blob/master/rb.c

class RBNode<T:RBNode<T>> {
  public var rbRed : Bool;
  public var rbLeft : T;
  public var rbRight : T;
  public var rbParent : T;
  public var rbNext : T;
  public var rbPrevious : T;
}

@:generic class RBTree<T:RBNode<T>> {

  public var root : T;

  public function new() {
    this.root = null;
    }

  public function rbInsertSuccessor(node : T, successor : T) {
    var parent;
    if (node != null) {
      // >>> rhill 2011-05-27: Performance: cache previous/next nodes
      successor.rbPrevious = node;
      successor.rbNext = node.rbNext;
      if (node.rbNext != null ) {
        node.rbNext.rbPrevious = successor;
        }
      node.rbNext = successor;
      // <<<
      if (node.rbRight != null) {
        // in-place expansion of node.rbRight.getFirst();
        node = node.rbRight;
        while (node.rbLeft != null) {node = node.rbLeft;}
        node.rbLeft = successor;
        }
      else {
        node.rbRight = successor;
        }
      parent = node;
      }
    // rhill 2011-06-07: if node is null, successor must be inserted
    // to the left-most part of the tree
    else if (this.root != null) {
      node = this.getFirst(this.root);
      // >>> Performance: cache previous/next nodes
      successor.rbPrevious = null;
      successor.rbNext = node;
      node.rbPrevious = successor;
      // <<<
      node.rbLeft = successor;
      parent = node;
      }
    else {
      // >>> Performance: cache previous/next nodes
      successor.rbPrevious = successor.rbNext = null;
      // <<<
      this.root = successor;
      parent = null;
      }
    successor.rbLeft = successor.rbRight = null;
    successor.rbParent = parent;
    successor.rbRed = true;
    // Fixup the modified tree by recoloring nodes and performing
    // rotations (2 at most) hence the red-black tree properties are
    // preserved.
    var grandpa, uncle;
    node = successor;
    while (parent != null && parent.rbRed) {
      grandpa = parent.rbParent;
      if (parent == grandpa.rbLeft) {
        uncle = grandpa.rbRight;
        if (uncle != null && uncle.rbRed) {
          parent.rbRed = uncle.rbRed = false;
          grandpa.rbRed = true;
          node = grandpa;
          }
        else {
          if (node == parent.rbRight) {
            this.rbRotateLeft(parent);
            node = parent;
            parent = node.rbParent;
            }
          parent.rbRed = false;
          grandpa.rbRed = true;
          this.rbRotateRight(grandpa);
          }
        }
      else {
        uncle = grandpa.rbLeft;
        if (uncle != null && uncle.rbRed) {
          parent.rbRed = uncle.rbRed = false;
          grandpa.rbRed = true;
          node = grandpa;
          }
        else {
          if (node == parent.rbLeft) {
            this.rbRotateRight(parent);
            node = parent;
            parent = node.rbParent;
            }
          parent.rbRed = false;
          grandpa.rbRed = true;
          this.rbRotateLeft(grandpa);
          }
        }
      parent = node.rbParent;
      }
    this.root.rbRed = false;
    }

  public function rbRemoveNode(node:T) {
    // >>> rhill 2011-05-27: Performance: cache previous/next nodes
    if (node.rbNext != null) {
      node.rbNext.rbPrevious = node.rbPrevious;
      }
    if (node.rbPrevious != null) {
      node.rbPrevious.rbNext = node.rbNext;
      }
    node.rbNext = node.rbPrevious = null;
    // <<<
    var parent = node.rbParent,
      left = node.rbLeft,
      right = node.rbRight,
      next;
    if (left == null) {
      next = right;
      }
    else if (right == null) {
      next = left;
      }
    else {
      next = this.getFirst(right);
      }
    if (parent != null) {
      if (parent.rbLeft == node) {
        parent.rbLeft = next;
        }
      else {
        parent.rbRight = next;
        }
      }
    else {
      this.root = next;
      }
    // enforce red-black rules
    var isRed;
    if (left != null && right != null) {
      isRed = next.rbRed;
      next.rbRed = node.rbRed;
      next.rbLeft = left;
      left.rbParent = next;
      if (next != right) {
        parent = next.rbParent;
        next.rbParent = node.rbParent;
        node = next.rbRight;
        parent.rbLeft = node;
        next.rbRight = right;
        right.rbParent = next;
        }
      else {
        next.rbParent = parent;
        parent = next;
        node = next.rbRight;
        }
      }
    else {
      isRed = node.rbRed;
      node = next;
      }
    // 'node' is now the sole successor's child and 'parent' its
    // new parent (since the successor can have been moved)
    if (node != null) {
      node.rbParent = parent;
      }
    // the 'easy' cases
    if (isRed) {return;}
    if (node != null && node.rbRed) {
      node.rbRed = false;
      return;
      }
    // the other cases
    var sibling;
    do {
      if (node == this.root) {
        break;
        }
      if (node == parent.rbLeft) {
        sibling = parent.rbRight;
        if (sibling.rbRed) {
          sibling.rbRed = false;
          parent.rbRed = true;
          this.rbRotateLeft(parent);
          sibling = parent.rbRight;
          }
        if ((sibling.rbLeft != null && sibling.rbLeft.rbRed) || (sibling.rbRight != null && sibling.rbRight.rbRed)) {
          if (sibling.rbRight == null || !sibling.rbRight.rbRed) {
            sibling.rbLeft.rbRed = false;
            sibling.rbRed = true;
            this.rbRotateRight(sibling);
            sibling = parent.rbRight;
            }
          sibling.rbRed = parent.rbRed;
          parent.rbRed = sibling.rbRight.rbRed = false;
          this.rbRotateLeft(parent);
          node = this.root;
          break;
          }
        }
      else {
        sibling = parent.rbLeft;
        if (sibling.rbRed) {
          sibling.rbRed = false;
          parent.rbRed = true;
          this.rbRotateRight(parent);
          sibling = parent.rbLeft;
          }
        if ((sibling.rbLeft != null && sibling.rbLeft.rbRed) || (sibling.rbRight != null && sibling.rbRight.rbRed)) {
          if (sibling.rbLeft == null || !sibling.rbLeft.rbRed) {
            sibling.rbRight.rbRed = false;
            sibling.rbRed = true;
            this.rbRotateLeft(sibling);
            sibling = parent.rbLeft;
            }
          sibling.rbRed = parent.rbRed;
          parent.rbRed = sibling.rbLeft.rbRed = false;
          this.rbRotateRight(parent);
          node = this.root;
          break;
          }
        }
      sibling.rbRed = true;
      node = parent;
      parent = parent.rbParent;
    } while (!node.rbRed);
    if (node != null) {node.rbRed = false;}
    }

  function rbRotateLeft(node:T) {
    var p = node,
      q = node.rbRight, // can't be null
      parent = p.rbParent;
    if (parent != null) {
      if (parent.rbLeft == p) {
        parent.rbLeft = q;
        }
      else {
        parent.rbRight = q;
        }
      }
    else {
      this.root = q;
      }
    q.rbParent = parent;
    p.rbParent = q;
    p.rbRight = q.rbLeft;
    if (p.rbRight != null) {
      p.rbRight.rbParent = p;
      }
    q.rbLeft = p;
    }

  function rbRotateRight(node:T) {
    var p = node,
      q = node.rbLeft, // can't be null
      parent = p.rbParent;
    if (parent != null) {
      if (parent.rbLeft == p) {
        parent.rbLeft = q;
        }
      else {
        parent.rbRight = q;
        }
      }
    else {
      this.root = q;
      }
    q.rbParent = parent;
    p.rbParent = q;
    p.rbLeft = q.rbRight;
    if (p.rbLeft != null) {
      p.rbLeft.rbParent = p;
      }
    q.rbRight = p;
    }

  public function getFirst(node:T) {
    while(node.rbLeft != null)
      node = node.rbLeft;
    return node;
    }

  public function getLast(node:T) {
    while( node.rbRight != null )
      node = node.rbRight;
    return node;
    }
}
