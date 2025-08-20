/*
 * -- copyright
 * OpenProject is an open source project management software.
 * Copyright (C) 2023 the OpenProject GmbH
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License version 3.
 *
 * OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
 * Copyright (C) 2006-2013 Jean-Philippe Lang
 * Copyright (C) 2010-2013 the ChiliProject Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * See COPYRIGHT and LICENSE files for more details.
 * ++
 */

import { Controller } from '@hotwired/stimulus';
import { ViewPortService } from './services/view-port-service';

export default class IndexController extends Controller<HTMLElement> {
  static values = {
    updateStreamsPath: String,
    sorting: String,
    pollingIntervalInMs: Number,
    filter: String,
    userId: Number,
    workPackageId: Number,
    notificationCenterPathName: String,
    lastServerTimestamp: String,
    showConflictFlashMessageUrl: String,
    unsavedChangesConfirmationMessage: String,
  };

  declare updateStreamsPathValue:string;
  declare sortingValue:string;
  declare lastServerTimestampValue:string;
  declare pollingIntervalInMsValue:number;
  declare notificationCenterPathNameValue:string;
  declare filterValue:string;
  declare userIdValue:number;
  declare workPackageIdValue:number;
  declare showConflictFlashMessageUrlValue:string;
  declare unsavedChangesConfirmationMessageValue:string;

  static targets = ['journalsContainer'];
  declare readonly journalsContainerTarget:HTMLElement;
  declare readonly hasJournalsContainerTarget:boolean;

  viewPortService:ViewPortService;

  connect() {
    this.viewPortService = new ViewPortService(this.notificationCenterPathNameValue);

    this.markAsConnected();
    this.setCssClasses();
  }

  disconnect() {
    this.markAsDisconnected();
  }

  setFilterToOnlyComments() { this.filterValue = 'only_comments'; }
  setFilterToOnlyChanges() { this.filterValue = 'only_changes'; }
  unsetFilter() { this.filterValue = ''; }

  adjustJournalContainerMarginWith(marginBottomPx:string) {
    // don't do this on mobile screens
    if (this.viewPortService.isMobile()) { return; }
    this.journalsContainerTarget.style.marginBottom = marginBottomPx;
  }

  resetJournalsContainerMargins():void {
    if (!this.hasJournalsContainerTarget) return;

    this.journalsContainerTarget.style.marginBottom = '';
    this.journalsContainerTarget.classList.add('work-packages-activities-tab-index-component--journals-container_with-initial-input-compensation');
  }

  setLastServerTimestampViaHeaders(headers:Headers) {
    if (headers.has('X-Server-Timestamp')) {
      this.lastServerTimestampValue = headers.get('X-Server-Timestamp') as string;
    }
  }

  showJournalsContainerInput() {
    if (!this.hasJournalsContainerTarget) return;

    this.journalsContainerTarget.classList.add('work-packages-activities-tab-index-component--journals-container_with-input-compensation');
  }

  hideJournalsContainerInput() {
    if (!this.hasJournalsContainerTarget) return;

    this.journalsContainerTarget.style.marginBottom = '';
    this.journalsContainerTarget.classList.remove('work-packages-activities-tab-index-component--journals-container_with-input-compensation');
    this.journalsContainerTarget.classList.add('work-packages-activities-tab-index-component--journals-container_with-initial-input-compensation');
  }

  // used in specs for timing
  private markAsConnected() { this.element.dataset.stimulusControllerConnected = 'true'; }
  private markAsDisconnected() { this.element.dataset.stimulusControllerConnected = 'false'; }

  private setCssClasses() {
    if (this.viewPortService.isWithinNotificationCenter()) {
      this.element.classList.add('work-packages-activities-tab-index-component--within-notification-center');
    }
    if (this.viewPortService.isWithinSplitScreen()) {
      this.element.classList.add('work-packages-activities-tab-index-component--within-split-screen');
    }
  }
}
