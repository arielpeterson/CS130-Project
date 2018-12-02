//
//  MyTableViewCell.swift
//  
//
//  Created by Ariel Peterson on 11/29/18.
//

import UIKit

protocol TableViewNew {
    func onDeleteCell(index: Int, cell: MyTableViewCell)
}

class MyTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    var cellDelegate: TableViewNew?
    var index: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        cellDelegate?.onDeleteCell(index: ((index?.row)!), cell: self)
        
        
    }


}


