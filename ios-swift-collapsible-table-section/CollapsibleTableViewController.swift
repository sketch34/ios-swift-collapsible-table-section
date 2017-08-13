//
//  CollapsibleTableViewController.swift
//  ios-swift-collapsible-table-section
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//

import UIKit

//
// MARK: - View Controller
//
class CollapsibleTableViewController: UITableViewController {
    
    var sections = sectionsData
    var selectedRow: IndexPath? = nil
    var expanding = false
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Auto resizing the height of the cell
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = "Apple Products"
    }
    
}

//
// MARK: - View Controller DataSource and Delegate
//
extension CollapsibleTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].collapsed ? 0 : sections[section].items.count
    }
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CollapsibleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell ??
            CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
        
        let item: Item = sections[indexPath.section].items[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.detailLabel.text = (selectedRow != nil) && indexPath.elementsEqual(selectedRow!) ? item.detail : ""
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = sections[section].name
        header.arrowLabel.text = ">"
        header.setCollapsed(sections[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt...")
        if(sections[indexPath.section].collapsed) {
            return;
        }
        else if(expanding) {
            print("ABORTING didSelectRowAt...")
            return
        }

        // Check if previous selected row is now in a collapsed section.
        // If it isn't add it to the list of rows to reload.
        let prevSelectedRow = selectedRow
        var reloadRows = [IndexPath]()
        if(prevSelectedRow != nil && !sections[prevSelectedRow!.section].collapsed) {
            reloadRows.append(prevSelectedRow!)
        }
        selectedRow = indexPath
        reloadRows.append(selectedRow!)
        self.tableView.reloadRows(at: reloadRows, with: .automatic)
    }

}

//
// MARK: - Section Header Delegate
//
extension CollapsibleTableViewController: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Probably need to wrap this in a begin/endUpdates batch.
        
        CATransaction.begin()
        print("Begin expanding.")
        expanding = true
        tableView.beginUpdates()
        CATransaction.setCompletionBlock {
            self.expanding = false
            print("   DONE expanding.")
        }
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        tableView.endUpdates()
        CATransaction.commit()
    }
    
}
