//
//  EditProfileView.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  EditProfileView.swift
//  ServU
//
//  Created by Quian Bowden on 7/21/25.
//  Updated by Assistant on 7/31/25.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    
    // Local state for editing
    @State private var editableBio: String = ""
    @State private var editableMajor: String = ""
    @State private var editablePhoneNumber: String = ""
    @State private var editableClassification: ClassificationLevel = .freshman
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        userProfile.college?.colorScheme.background ?? Color(.systemGray6),
                        Color(.systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Editable Fields
                        editableFieldsView
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(userProfile.college?.primaryColor ?? .blue)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadCurrentValues()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Profile Image (non-editable here, can be changed from main profile)
            Group {
                if let image = userProfile.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(userProfile.college?.primaryColor ?? .blue, lineWidth: 3)
            )
            
            // Non-editable info
            VStack(spacing: 4) {
                Text(userProfile.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(userProfile.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let college = userProfile.college {
                    Text(college.name)
                        .font(.subheadline)
                        .foregroundColor(college.primaryColor)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Editable Fields
    private var editableFieldsView: some View {
        VStack(spacing: 20) {
            // Bio Section
            EditableSection(title: "Bio", icon: "text.quote") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell other students about yourself")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $editableBio)
                        .frame(minHeight: 80)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
            }
            
            // Classification Section
            EditableSection(title: "Classification", icon: "graduationcap.fill") {
                Picker("Classification", selection: $editableClassification) {
                    ForEach(ClassificationLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Major Section
            EditableSection(title: "Major", icon: "book.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What are you studying?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter your major", text: $editableMajor)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            // Phone Number Section
            EditableSection(title: "Phone Number", icon: "phone.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("For booking confirmations and updates")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("(555) 123-4567", text: $editablePhoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                }
            }
        }
    }
    
    // MARK: - Methods
    private func loadCurrentValues() {
        editableBio = userProfile.bio
        editableMajor = userProfile.major
        editablePhoneNumber = userProfile.phoneNumber
        editableClassification = userProfile.classificationLevel
    }
    
    private func saveChanges() {
        // Update the user profile with edited values
        userProfile.bio = editableBio
        userProfile.major = editableMajor
        userProfile.phoneNumber = formatPhoneNumber(editablePhoneNumber)
        userProfile.classificationLevel = editableClassification
        
        // TODO: Save to backend/local storage
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        // Basic phone number formatting
        let digits = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard digits.count == 10 else { return number }
        
        let start = digits.startIndex
        let areaCode = String(digits[start..<digits.index(start, offsetBy: 3)])
        let middle = String(digits[digits.index(start, offsetBy: 3)..<digits.index(start, offsetBy: 6)])
        let end = String(digits[digits.index(start, offsetBy: 6)...])
        
        return "(\(areaCode)) \(middle)-\(end)"
    }
}

// MARK: - Editable Section Component
struct EditableSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    EditProfileView(userProfile: UserProfile())
}