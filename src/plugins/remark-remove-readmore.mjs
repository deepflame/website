import { visit } from 'unist-util-visit';

/**
 * Remark plugin to remove READMORE markers from markdown content
 */
export function remarkRemoveReadmore() {
  return (tree) => {
    visit(tree, 'text', (node, index, parent) => {
      if (node.value.includes('READMORE')) {
        node.value = node.value.replace(/READMORE\n?/g, '');
        
        // If the text node is now empty, remove it
        if (node.value.trim() === '' && parent && index !== null) {
          parent.children.splice(index, 1);
          return [visit.SKIP, index];
        }
      }
    });
    
    // Also check for paragraph nodes that contain only READMORE
    visit(tree, 'paragraph', (node, index, parent) => {
      if (node.children.length === 1 && 
          node.children[0].type === 'text' && 
          node.children[0].value.trim() === '') {
        if (parent && index !== null) {
          parent.children.splice(index, 1);
          return [visit.SKIP, index];
        }
      }
    });
  };
}

