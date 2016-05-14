Feature: Generate specs with fabricators

  Background:
    Given I set up devise-specs

  Scenario: running a devise generator with Fabrication installed
    Given I install fabrication
    When I run `rails generate devise Admin`
    Then the output should contain:
      """
            invoke  specs
              gsub    spec/rails_helper.rb
            insert    spec/fabricators/admin_fabricator.rb
            create    spec/support/helpers.rb
            create    spec/features/admin_signs_up_spec.rb
            create    spec/features/admin_signs_in_spec.rb
            create    spec/features/admin_signs_out_spec.rb
            create    spec/features/admin_resets_password_spec.rb
      """
    And the file "spec/features/admin_signs_up_spec.rb" should contain:
      """
      require 'rails_helper'

      feature 'Admin signs up' do
        scenario 'with valid data' do
          visit new_admin_registration_path

          fill_in 'Email', with: 'username@example.com'
          fill_in 'Password', with: 'password'
          fill_in 'Password confirmation', with: 'password'
          click_button 'Sign up'

          expect(page).to have_text 'Welcome! You have signed up successfully.'
        end

        scenario 'with invalid data' do
          visit new_admin_registration_path

          click_button 'Sign up'

          expect(page).to have_text "Email can't be blank"
          expect(page).to have_text "Password can't be blank"
        end
      end
      """
    And the file "spec/features/admin_signs_in_spec.rb" should contain:
      """
      require 'rails_helper'

      feature 'Admin signs in' do
        scenario 'with valid credentials' do
          admin = Fabricate :admin

          sign_in admin

          expect(page).to have_text 'Signed in successfully.'
        end

        scenario 'with invalid credentials' do
          admin = Fabricate.build :admin

          sign_in admin

          expect(page).to have_text 'Invalid Email or password.'
        end
      end
      """
    And the file "spec/features/admin_signs_out_spec.rb" should contain:
      """
      require 'rails_helper'

      feature 'Admin signs out' do
        scenario 'admin signed in' do
          admin = Fabricate :admin

          sign_in admin

          click_link 'Sign Out'

          expect(page).to have_text 'Signed out successfully.'
        end
      end
      """
    And the file "spec/features/admin_resets_password_spec.rb" should contain:
      """
      require 'rails_helper'

      feature 'Admin resets a password' do
        scenario 'admin enters a valid email' do
          admin = Fabricate :admin

          visit new_admin_password_path

          fill_in 'Email', with: admin.email
          click_button 'Send me reset password instructions'

          expect(page).to have_text 'You will receive an email with instructions'
        end

        scenario 'admin enters an invalid email' do
          visit new_admin_password_path

          fill_in 'Email', with: 'username@example.com'
          click_button 'Send me reset password instructions'

          expect(page).to have_text 'Email not found'
        end

        scenario 'admin changes password' do
          token = Fabricate(:admin).send_reset_password_instructions

          visit edit_admin_password_path(reset_password_token: token)

          fill_in 'New password', with: 'p4ssw0rd'
          fill_in 'Confirm new password', with: 'p4ssw0rd'
          click_button 'Change my password'

          expect(page).to have_text 'Your password has been changed successfully.'
        end

        scenario 'password reset token is invalid' do
          visit edit_admin_password_path(reset_password_token: 'token')

          fill_in 'New password', with: 'p4ssw0rd'
          fill_in 'Confirm new password', with: 'p4ssw0rd'
          click_button 'Change my password'

          expect(page).to have_text 'Reset password token is invalid'
        end
      end
      """
