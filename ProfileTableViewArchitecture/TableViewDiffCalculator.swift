//
//  TableViewDiffCalculator.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import Foundation

// MARK: - Reloadable Sections

struct ReloadableSection<T: Equatable>: Equatable
{
   var key: String // unique id for items
   var rows: [ReloadableRow<T>] // [items] for this section usually
   var index: Int // index of section item in datasource
    
    static func ==(lhs: ReloadableSection, rhs: ReloadableSection) -> Bool
    {
       return lhs.key == rhs.key && lhs.rows == rhs.rows
    }
}

// MARK: - Reloadable Cells

struct ReloadableRow<T: Equatable>: Equatable
{
    var key: String
    var value: T
    var index: Int // index of row in datasource
    
    static func ==(lhs: ReloadableRow, rhs: ReloadableRow) -> Bool
    {
       return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

// MARK: - Diff Calculations

class SectionChanges
{
    var inserts = [Int]()
    var deletes = [Int]()
    var rowChanges = RowChanges()

    var sectionsToInsert: IndexSet {
        return IndexSet(self.inserts)
    }
    
    var sectionsToDelete: IndexSet {
        return IndexSet(self.deletes)
    }
}

class RowChanges
{
   var rowsToInsert = [IndexPath]()
   var rowsToDelete = [IndexPath]()
   var rowsToReload = [IndexPath]()
}

class TableViewDiffCalculator
{
    func calculate<T>(oldSections: [ReloadableSection<T>], newSections: [ReloadableSection<T>]) -> SectionChanges
    {
        // capture the diffs in SectionChanges & CellChanges
        let sectionChanges = SectionChanges()
        let rowChanges = RowChanges()
        
        // get all the keys involved - the ones being deleted, updated, and inserted
        let uniqueSectionChanges = (oldSections + newSections)
            .map { $0.key }
            .filterDuplicates()
        
        // now figure out which sections were changed, deleted, or are new and need to be inserted
        for key in uniqueSectionChanges {
            let oldSection = oldSections.first { $0.key == key }
            let newSection = newSections.first { $0.key == key }
            
            // if section exists in old & new & they are different (could be the same) -> section has been updated, calculate the row diff
            if let oldSection = oldSection, let newSection = newSection {
                if oldSection != newSection {
                    let calculatedRowChanges = self.calculateRowChanges(oldSection: oldSection, newSection: newSection)
                    rowChanges.rowsToReload.append(contentsOf: calculatedRowChanges.rowsToReload)
                    rowChanges.rowsToDelete.append(contentsOf: calculatedRowChanges.rowsToDelete)
                    rowChanges.rowsToInsert.append(contentsOf: calculatedRowChanges.rowsToInsert)
                }
            }
            // if section only exists in old -> it's been deleted
            else if let oldSection = oldSection {
                sectionChanges.deletes.append(oldSection.index)
            }
            // if section exists in only new -> it's been inserted
            else if let newSection = newSection {
                sectionChanges.inserts.append(newSection.index)
            }
        }
        
        sectionChanges.rowChanges = rowChanges
        return sectionChanges
    }
    
    func calculateRowChanges<T>(oldSection: ReloadableSection<T>, newSection: ReloadableSection<T>) -> RowChanges
    {
        // capture the diff of the rows (cells) in rowChanges - the same as we do w/ sections
        let rowChanges = RowChanges()
        let oldRows = oldSection.rows
        let newRows = newSection.rows
        
        // get all the keys involved - the ones being deleted, updated, and inserted
        let uniqueCellChanges = (oldRows + newRows)
            .map { $0.key }
            .filterDuplicates()
        
        // figure out which keys were changed, deleted, or are new and need to be inserted
        for key in uniqueCellChanges {
            let oldRow = oldRows.first { $0.key == key }
            let newRow = newRows.first { $0.key == key }
            
            // if row exists in old & new & they are different (could be the same) -> reload the row
            if let oldRow = oldRow, let newRow = newRow {
                if oldRow != newRow {
                    rowChanges.rowsToReload.append(IndexPath(row: oldRow.index, section: oldSection.index))
                }
            }
            // if row only exists in old -> it's been deleted
            else if let oldRow = oldRow {
                rowChanges.rowsToDelete.append(IndexPath(row: oldRow.index, section: oldSection.index))
            }
            // if row only exists in new -> it's been inserted
            else if let newRow = newRow {
                rowChanges.rowsToInsert.append(IndexPath(row: newRow.index, section: newSection.index))
            }
        }
    
        return rowChanges
    }
}
