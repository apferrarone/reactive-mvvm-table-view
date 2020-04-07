//
//  TableViewDiffCalculator.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import Foundation

// MARK: - Reloadable Sections

protocol ReloadableSection
{
    var sectionId: String { get } // unique id for items
    var sectionHeader: ReloadableSectionHeader? { get }
    var rows: [ReloadableRow] { get } // [items] for this section usually
//    func isEqualTo(_ other: ReloadableSection) -> Bool
}

extension ReloadableSection
{
//    func isEqualTo(_ other: ReloadableSection) -> Bool
//    {
//        return self.sectionId == other.sectionId && self.rows == other.rows
//    }
    
    var sectionHeader: ReloadableSectionHeader? {
        return nil // default no header
    }
}

struct ReloadableSectionData
{
    var sections = [ReloadableSection]()
    
    func index(of section: ReloadableSection) -> Int?
    {
        return self.sections.firstIndex { $0.sectionId == section.sectionId }
    }

    subscript(key: String) -> ReloadableSection? {
        get {
            return self.sections.first { $0.sectionId == key }
        }
    }
}

// MARK: - Reloadable Section Header

struct ReloadableSectionHeader: Equatable
{
    var value: CustomStringConvertible
    
    static func ==(lhs: ReloadableSectionHeader, rhs: ReloadableSectionHeader) -> Bool
    {
        return lhs.value.description == rhs.value.description
    }
}

// MARK: - Reloadable Rows

struct ReloadableRow: Equatable
{
    let id: String
    var value: CustomStringConvertible // to compare for row changes
    
    static func ==(lhs: ReloadableRow, rhs: ReloadableRow) -> Bool
    {
        return lhs.id == rhs.id && lhs.value.description == rhs.value.description
    }
}

struct ReloadableRowData
{
    var rows = [ReloadableRow]()
    
    func index(of row: ReloadableRow) -> Int?
    {
        return self.rows.firstIndex { $0.id == row.id }
    }
    
    subscript(key: String) -> ReloadableRow? {
        get {
            return self.rows.first { $0.id == key }
        }
    }
}

// MARK: - Diff Calculations

struct SectionChanges
{
    var inserts = [Int]()
    var deletes = [Int]()
    var rowChanges = RowChanges()

    // There is no UIKit way to reload a section header - just the entire section,
    // but clients of TableViewDiffCalculator may want to implement something custom so
    // I'm calling this sectionHeadersToReload instead of just sectionsToReload
    var sectionHeaderReloads = [Int]()

    var sectionsToInsert: IndexSet {
        return IndexSet(self.inserts)
    }
    
    var sectionsToDelete: IndexSet {
        return IndexSet(self.deletes)
    }
    
    var sectionHeadersToReload: IndexSet {
        return IndexSet(self.sectionHeaderReloads)
    }
}

struct RowChanges
{
   var rowsToInsert = [IndexPath]()
   var rowsToDelete = [IndexPath]()
   var rowsToReload = [IndexPath]()
}

class TableViewDiffCalculator
{
    func calculateChanges(oldSections: [ReloadableSection], newSections: [ReloadableSection]) -> SectionChanges
    {
        // capture the diffs in SectionChanges & CellChanges
        var sectionChanges = SectionChanges()
        var rowChanges = RowChanges()
        
        // get all the keys involved - the ones being deleted, updated, and inserted
        let uniqueSectionChanges = (oldSections + newSections)
            .map { $0.sectionId }
            .filterDuplicates()
                
        let oldSectionData = ReloadableSectionData(sections: oldSections)
        let newSectionData = ReloadableSectionData(sections: newSections)
        
        // now figure out which sections were changed, deleted, or are new and need to be inserted
        for id in uniqueSectionChanges {
            // if section exists in old & new & they are different (could be the same) -> section has been updated
            if let oldSection = oldSectionData[id],
                let newSection = newSectionData[id],
                let oldSectionIndex = oldSectionData.index(of: oldSection),
                let newSectionIndex = newSectionData.index(of: newSection) {
                // if rows have changed, calculate the row diff
                if oldSection.rows != newSection.rows {
                    let calculatedRowChanges = self.calculateRowChanges(oldSection: oldSection, oldSectionIndex: oldSectionIndex, newSection: newSection, newSectionIndex: newSectionIndex)
                    rowChanges.rowsToReload.append(contentsOf: calculatedRowChanges.rowsToReload)
                    rowChanges.rowsToDelete.append(contentsOf: calculatedRowChanges.rowsToDelete)
                    rowChanges.rowsToInsert.append(contentsOf: calculatedRowChanges.rowsToInsert)
                }
                // might need to put this above and bail since reloading the whole section would take care of the rows,
                // but let's see if we can reload the section and the rows at the same time
                if oldSection.sectionHeader != newSection.sectionHeader {
                    sectionChanges.sectionHeaderReloads.append(newSectionIndex)
                }
            }
            // if section only exists in old -> it's been deleted
            else if let oldSection = oldSectionData[id], let oldSectionIndex = oldSectionData.index(of: oldSection) {
                sectionChanges.deletes.append(oldSectionIndex)
            }
            // if section exists in only new -> it's been inserted
            else if let newSection = newSectionData[id], let newSectionIndex = newSectionData.index(of: newSection) {
                sectionChanges.inserts.append(newSectionIndex)
            }
        }
        
        sectionChanges.rowChanges = rowChanges
        return sectionChanges
    }
    
    private func calculateRowChanges(oldSection: ReloadableSection, oldSectionIndex: Int, newSection: ReloadableSection, newSectionIndex: Int) -> RowChanges
    {
        // capture the diff of the rows (cells) in rowChanges - the same as we do w/ sections
        var rowChanges = RowChanges()
        
        // get all the keys involved - the ones being deleted, updated, and inserted
        let uniqueCellChanges = (oldSection.rows + newSection.rows)
            .map { $0.id }
            .filterDuplicates()
        
        let oldRowData = ReloadableRowData(rows: oldSection.rows)
        let newRowData = ReloadableRowData(rows: newSection.rows)
        
        // figure out which keys were changed, deleted, or are new and need to be inserted
        for id in uniqueCellChanges {
            // if row exists in old & new & they are different (could be the same) -> reload the row
            if let oldRow = oldRowData[id], let newRow = newRowData[id] {
                if oldRow != newRow, let rowIndex = oldRowData.index(of: oldRow) {
                    rowChanges.rowsToReload.append(IndexPath(row: rowIndex, section: oldSectionIndex))
                }
            }
            // if row only exists in old -> it's been deleted
            else if let oldRow = oldRowData[id], let rowIndex = oldRowData.index(of: oldRow) {
                rowChanges.rowsToDelete.append(IndexPath(row: rowIndex, section: oldSectionIndex))
            }
            // if row only exists in new -> it's been inserted
            else if let newRow = newRowData[id], let rowIndex = newRowData.index(of: newRow) {
                rowChanges.rowsToInsert.append(IndexPath(row: rowIndex, section: newSectionIndex))
            }
        }
    
        return rowChanges
    }
}

extension Array where Element: Hashable
{
    // Remove duplicates from the array, preserving the items order
    func filterDuplicates() -> Array<Element>
    {
        var set = Set<Element>()
        var filteredArray = Array<Element>()

        for item in self {
            // if it was successfully inserted into the set, it did not already exist and is unique
            if set.insert(item).inserted {
                filteredArray.append(item)
            }
        }

        return filteredArray
    }
}
