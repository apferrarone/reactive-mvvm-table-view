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
        
    static func ==(lhs: ReloadableSection, rhs: ReloadableSection) -> Bool
    {
       return lhs.key == rhs.key && lhs.rows == rhs.rows
    }
}

struct ReloadableSectionData<T: Equatable>
{
    var sections = [ReloadableSection<T>]()
    
    func index(of section: ReloadableSection<T>) -> Int?
    {
        return self.sections.firstIndex { $0.key == section.key }
    }
    
    subscript(key: String) -> ReloadableSection<T>? {
        get {
            return self.sections.first { $0.key == key }
        }
    }
}

// MARK: - Reloadable Rows

struct ReloadableRow<T: Equatable>: Equatable
{
    var key: String
    var value: T
    
    static func ==(lhs: ReloadableRow, rhs: ReloadableRow) -> Bool
    {
       return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

struct ReloadableRowData<T: Equatable>
{
    var rows = [ReloadableRow<T>]()
    
    func index(of row: ReloadableRow<T>) -> Int?
    {
        return self.rows.firstIndex { $0.key == row.key }
    }
    
    subscript(key: String) -> ReloadableRow<T>? {
        get {
            return self.rows.first { $0.key == key }
        }
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
            let oldSectionData = ReloadableSectionData(sections: oldSections)
            let oldSection = oldSectionData[key]
            let newSectionData = ReloadableSectionData(sections: newSections)
            let newSection = newSectionData[key]
            
            // if section exists in old & new & they are different (could be the same) -> section has been updated, calculate the row diff
            if let oldSection = oldSection, let newSection = newSection {
                if oldSection != newSection,
                    let newSectionIndex = newSectionData.index(of: newSection),
                    let oldSectionIndex = oldSectionData.index(of: oldSection) {
                    let calculatedRowChanges = self.calculateRowChanges(oldSection: oldSection, oldSectionIndex: oldSectionIndex, newSection: newSection, newSectionIndex: newSectionIndex)
                    rowChanges.rowsToReload.append(contentsOf: calculatedRowChanges.rowsToReload)
                    rowChanges.rowsToDelete.append(contentsOf: calculatedRowChanges.rowsToDelete)
                    rowChanges.rowsToInsert.append(contentsOf: calculatedRowChanges.rowsToInsert)
                }
            }
            // if section only exists in old -> it's been deleted
            else if let oldSection = oldSection, let oldSectionIndex = oldSections.firstIndex(where: { $0.key == oldSection.key }) {
                sectionChanges.deletes.append(oldSectionIndex)
            }
            // if section exists in only new -> it's been inserted
            else if let newSection = newSection, let newSectionIndex = newSections.firstIndex(where: { $0.key == newSection.key }) {
                sectionChanges.inserts.append(newSectionIndex)
            }
        }
        
        sectionChanges.rowChanges = rowChanges
        return sectionChanges
    }
    
    func calculateRowChanges<T>(oldSection: ReloadableSection<T>, oldSectionIndex: Int, newSection: ReloadableSection<T>, newSectionIndex: Int) -> RowChanges
    {
        // capture the diff of the rows (cells) in rowChanges - the same as we do w/ sections
        let rowChanges = RowChanges()
        
        // get all the keys involved - the ones being deleted, updated, and inserted
        let uniqueCellChanges = (oldSection.rows + newSection.rows)
            .map { $0.key }
            .filterDuplicates()
        
        // figure out which keys were changed, deleted, or are new and need to be inserted
        for key in uniqueCellChanges {
            let oldRowData = ReloadableRowData(rows: oldSection.rows)
            let oldRow = oldRowData[key]
            let newRowData = ReloadableRowData(rows: newSection.rows)
            let newRow = newRowData[key]
            
            // if row exists in old & new & they are different (could be the same) -> reload the row
            if let oldRow = oldRow, let newRow = newRow {
                if oldRow != newRow, let rowIndex = oldRowData.index(of: oldRow) {
                    rowChanges.rowsToReload.append(IndexPath(row: rowIndex, section: oldSectionIndex))
                }
            }
            // if row only exists in old -> it's been deleted
            else if let oldRow = oldRow, let rowIndex = oldRowData.index(of: oldRow) {
                rowChanges.rowsToDelete.append(IndexPath(row: rowIndex, section: oldSectionIndex))
            }
            // if row only exists in new -> it's been inserted
            else if let newRow = newRow, let rowIndex = newRowData.index(of: newRow) {
                rowChanges.rowsToInsert.append(IndexPath(row: rowIndex, section: newSectionIndex))
            }
        }
    
        return rowChanges
    }
}
