import { Injectable } from '@nestjs/common';
import { GroupRepository } from '../entities/group.repository';
import { CreateGroupRequest } from '../dto/create-group-request.dto';
import { User } from '../../../users/domain/user.domain';
import { UserGroupGrade } from '../domain/user-group-grade';
import { Transactional } from '../../../config/transaction-manager';
import { GroupResponse } from '../dto/group-response.dto';
import { GroupListResponse } from '../dto/group-list-response';

@Injectable()
export class GroupService {
  constructor(private readonly groupRepository: GroupRepository) {}

  @Transactional()
  async create(user: User, createGroupRequest: CreateGroupRequest) {
    const group = createGroupRequest.toModel();
    group.addMember(user, UserGroupGrade.LEADER);
    return GroupResponse.from(await this.groupRepository.saveGroup(group));
  }

  async getGroups(userId: number) {
    const groups = await this.groupRepository.findByUserId(userId);
    return new GroupListResponse(groups);
  }
}
