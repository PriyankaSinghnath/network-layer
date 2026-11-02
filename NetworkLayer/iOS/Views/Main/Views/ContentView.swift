//
//  MainView.swift
//  NetworkLayer
//
//  Created by Shipra on 02/11/26.
//

import SwiftUI

struct MainView: View {
    @StateObject private var session: AppSession
    @StateObject private var productViewModel: ProductViewModel

    init(api: APIManager) {
        _session = StateObject(wrappedValue: AppSession(api: api))
        _productViewModel = StateObject(wrappedValue: ProductViewModel(manager: api))
    }

    var body: some View {
        Group {
            if session.accessToken == nil {
                AuthenticationView(session: session)
            } else {
                TabView {
                    DashboardView(username: session.username)
                        .tabItem { Label("Dashboard", systemImage: "chart.bar.xaxis") }

                    ProductListView(viewModel: productViewModel)
                        .tabItem { Label("Products", systemImage: "square.grid.2x2") }

                    AccountView(username: session.username) {
                        Task { await session.logout() }
                    }
                    .tabItem { Label("Account", systemImage: "person.crop.circle") }
                }
            }
        }
    }
}

private struct AuthenticationView: View {
    @ObservedObject var session: AppSession
    @State private var isSigningUp = false
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "shippingbox")
                .font(.system(size: 42, weight: .regular))
                .foregroundStyle(.primary)
                .padding(.bottom, 24)

            Text(isSigningUp ? "Create your account" : "Sign in")
                .font(.system(size: 30, weight: .semibold))
                .tracking(-0.5)
            Text(isSigningUp ? "Get started with your account." : "Sign in to continue to your account.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 32)

            VStack(spacing: 12) {
                if isSigningUp {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                }
                TextField("Username", text: $username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $password)
                    .textContentType(isSigningUp ? .newPassword : .password)
                    .textFieldStyle(.roundedBorder)
            }

            if let error = session.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
            }

            Button {
                Task {
                    await session.authenticate(
                        username: username,
                        email: email,
                        password: password,
                        isSigningUp: isSigningUp
                    )
                }
            } label: {
                Group {
                    if session.isWorking {
                        ProgressView().tint(.white)
                    } else {
                        Text(isSigningUp ? "Create Account" : "Continue")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .background(Color.primary, in: RoundedRectangle(cornerRadius: 12))
            }
            .disabled(session.isWorking)
            .padding(.top, 20)

            Button {
                isSigningUp.toggle()
                session.errorMessage = nil
            } label: {
                HStack(spacing: 4) {
                    Text(isSigningUp ? "Already have an account?" : "New here?")
                        .foregroundStyle(.secondary)
                    Text(isSigningUp ? "Sign in" : "Create an account")
                        .foregroundStyle(.primary)
                        .fontWeight(.medium)
                }
                .font(.footnote)
                .padding(.top, 22)
            }
            Spacer()
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 440)
        .frame(maxWidth: .infinity)
    }
}

private struct DashboardView: View {
    let username: String

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome back, \(username)")
                    .font(.largeTitle.bold())
                Text("Your workspace at a glance.")
                    .foregroundStyle(.secondary)

                Label("Manage your product catalog", systemImage: "shippingbox")
                    .font(.headline)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                Spacer()
            }
            .padding(24)
            .navigationTitle("Dashboard")
        }
    }
}

private struct ProductListView: View {
    @ObservedObject var viewModel: ProductViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView("Loading products…")
                } else if let errorMessage = viewModel.errorMessage, viewModel.products.isEmpty {
                    ContentUnavailableView("Couldn’t Load Products", systemImage: "wifi.exclamationmark", description: Text(errorMessage))
                } else {
                    List(viewModel.products) { product in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(product.title).font(.headline)
                            Text(product.description).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                            Text(product.price, format: .currency(code: "USD"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .overlay {
                        if viewModel.products.isEmpty && !viewModel.isLoading {
                            ContentUnavailableView("No Products", systemImage: "shippingbox")
                        }
                    }
                }
            }
            .navigationTitle("Products")
            .toolbar {
                Button("Reload", systemImage: "arrow.clockwise") {
                    Task { await viewModel.loadProducts() }
                }
            }
            .task { await viewModel.loadProducts() }
        }
    }
}

private struct AccountView: View {
    let username: String
    let onLogout: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    LabeledContent("Username", value: username)
                }
                Section {
                    Button("Sign Out", role: .destructive, action: onLogout)
                }
            }
            .navigationTitle("Account")
        }
    }
}

#Preview {
    MainView(api: APIManager(networkManager: NetworkManager()))
}
